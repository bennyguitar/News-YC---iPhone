![Screenshot](https://raw.github.com/bennyguitar/libHN/master/Screenshots/screen1-01.png)

The definitive Cocoa framework for adding HackerNews to your iOS/Mac app. This mini library includes features such as grabbing Posts (including filtering by Top, Ask, New, Jobs, Best), Comments, Logging in, and Submitting new posts/comments!

---------------------

## Table of Contents

* [Installing](#getting-started)
* [HNManager](#hnmanager)
* HN Web Calls
  * [Fetching Posts](#fetching-posts)
  * [Fetching Comments for a Post](#fetching-comments)
  * [Logging In/Out](#logging-inout)
  * [Submitting a Post](#submitting-a-new-post)
  * [Reply to a Post/Comment](#replying-to-a-postcomment)
  * [Voting on a Post/Comment](#voting-on-a-postcomment)
  * [Fetching submissions for a Username](#fetching-all-submissions-for-a-user)
* [HNManager Auxiliary Methods](#auxiliary-methods)
* [Designing for the Future, and beyond!](#designing-for-the-future-and-beyond)
* [Apps that use libHN](#apps-that-use-libhn)
* [License](#license)

## Getting Started

Installing libHN is a breeze. First things first, add all of the classes in the top-level **libHN Classes** folder inside of this repository into your app. Done? Good. Now, just <code>#import "libHN.h"</code> in any of your controllers, classes, or views you plan on using libHN in. That's it. We're done here.

Classes to add:
* libHN.h
* HNManager.{h,m}
* HNUtilities.{h,m}
* HNWebService.{h,m}
* HNPost.{h,m}
* HNComment.{h,m}
* HNUser.{h,m}
* HNCommentLink.{h,m}

**CocoaPods**

If CocoaPods suits your flavor of dependency management, then there is a .podspec here for you as well. Just add the following line to your Podfile, and install your pods to get started with libHN the easy way.

```ruby
pod 'libHN'
```

---------------------

## HNManager

**HNManager** is going to be your go-to class for using libHN. Every action flows through there - all web calls, session generation, etc. It's your conduit to HackerNews functionality. HNManager is a Singleton class, and has a <code>sharedManager</code> initialization that you should use to make sure everything gets routed correctly through the Manager.

**Starting a Session**

Add the code snippet, <code>[[HNManager sharedManager] startSession]</code>, to begin a session of the HNManager's sharedManager object. This method will log in a user if he/she has logged in on the app previously, using the Cookie that is stored on the device. For best practices, add this method to the <code>- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions</code> method in your <code>AppDelegate.m</code> class before the method returns. This will ensure that setting up the manager is the first thing that happens when your app launches, and that any users that are logged in, will log in immediately as well.

---------------------

## Fetching Posts

Because of the way HackerNews is set up, there are two methods for getting posts. The first one <code>loadPostsWithFilter:completion:</code>, is your beginning method to retrieving posts based on a filter. So if you go to the [HN homepage](https://news.ycombinator.com/) this is what you'd get if you call this method and use <code>PostFilterTypeTop</code> as the PostFilterType parameter.

If you notice on the homepage, at the very bottom, there's a "More" button. Click that then look at the URL Bar. Notice the funky string that looks like this: "fnid=kS3LAcKvtXPC85KnoQszPW" at the end of the URL? HackerNews works on assigning an fnid, or basically a SessionKey, to determine what page you are going to and the authenticity of its request/response. This is used for every action on the site except for getting the first 30 links of any post type. This is where the second method comes in, <code>loadPostsWithUrlAddition:completion:</code>, which takes in a Url Addition string to determine what posts should come next.

**loadPostsWithFilter**

This method takes in a PostFilterType parameter and returns an NSArray of <code>HNPost</code> objects. The various PostFilterTypes, and the types of posts you receive are listed below:

* PostFilterTypeTop - [HomePage](https://news.ycombinator.com/)
* PostFilterTypeAsk - [Ask HN](https://news.ycombinator.com/ask)
* PostFilterTypeNew - [Newest Posts](https://news.ycombinator.com/newest)
* PostFilterTypeJobs - [HN Jobs](https://news.ycombinator.com/jobs)
* PostFilterTypeBest - [Highest Rated Posts Recently](https://news.ycombinator.com/best)

And here's how to use this:

```objc
[[HNManager sharedManager] loadPostsWithFilter:(PostFilterType)filter completion:(NSArray *posts){
  if (posts) {
    // Posts were successfuly retrieved
  }
  else {
    // No posts retrieved, handle the error
  }
}];
```

**loadPostsWithUrlAddition**

Now that you've gotten the first set of posts, use this method to keep retrieving posts in that Filter. The FNID parameter is mostly taken care of with the <code>postUrlAddition</code> property of the HNManager. If you wanted to do something custom, you could pass in a string of your choosing here, but I recommend sticking with the default postUrlAddition property. Every time you load posts with any of these two methods, the postUrlAddition parameter is updated on the sharedManager.

```objc
[[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition] completion:(NSArray *posts){
  if (posts) {
    // Posts were successfuly retrieved
  }
  else {
    // No posts retrieved, handle the error
  }
}];
```

**HNpost.{h,m}**

The actual HNPost object is fairly simple. It just contains the metadata about the post like Title, and the URL. There is a class method here that scans through the HTML passed in to return the array of posts that the two web methods above return. This is the low-level stuff that you should never have to mess with, but might be beneficial to pore over if you'd like to learn more or implement changes yourself.

```objc
// HNPost.h

// Enums
typedef NS_ENUM(NSInteger, PostType) {
    PostTypeDefault,
    PostTypeAskHN,
    PostTypeJobs
};

// Properties
@property (nonatomic, assign) PostType *Type;
@property (nonatomic,retain) NSString *Username;
@property (nonatomic, retain) NSURL *Url;
@property (nonatomic, retain) NSString *UrlDomain;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, assign) int Points;
@property (nonatomic, assign) int CommentCount;
@property (nonatomic, retain) NSString *PostId;
@property (nonatomic, retain) NSString *TimeCreatedString;

// Methods
+ (NSArray *)parsedPostsFromHTML:(NSString *)html FNID:(NSString **)fnid;
```

---------------------

## Fetching Comments

There's only one method to load comments, and naturally, it follows from loading the Posts. After you load your Posts, you can pass one in to the following method to return an array of <code>HNComment</code> objects. If you go to an AskHN post, you'll notice that the text is inline with the rest of the comments (separated by a text area for a reply), so I decided to include that self-post as the first comment in the returned array. You can tell what this is by using the <code>Type</code> property of the HNComment. The same goes for an HNJobs post. Sometimes, a Jobs post will be a self-post to HN, instead of an external link, so you can capture this data in the exact same way as a regular comment. If the Type == HNCommentTypeJobs, then you know you have a self jobs post.

The main reason I did this for AskHN and Jobs was to get any Link data out of the post, and to present things nicely to the user inline with any other comments inside my own personal app.

```objc
[[HNManager sharedManager] loadCommentsFromPost:(HNPost *)post completion:(NSArray *comments){
  if (comments) {
    // Comments retrieved.
  }
  else {
    // No comments retrieved, handle the error
  }
}];
```

**HNComment.{h,m}**

Similar to the HNPost object, HNComment features a handy class method that generates an NSArray of HNComments by parsing the HTML itself. Again, I'd look this over just to get a feel for how it works.

```objc
// HNComment.h

// Enums
typedef NS_ENUM(NSInteger, HNCommentType) {
    HNCommentTypeDefault,
    HNCommentTypeAskHN,
    HNCommentTypeJobs
};

// Properties
@property (nonatomic, assign) HNCommentType *Type;
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentId;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *ReplyURLString;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSArray *Links;

// Methods
+ (NSArray *)parsedCommentsFromHTML:(NSString *)html;
```

---------------------

## Logging In/Out

User related actions are a vital aspect of being part of the HackerNews community. I mean, if you can't be active in discussion or submit interesting links, then you might as well be a bystander. Unfortunately most HN Reader iOS/Mac apps neglect this part of the community and focus more on the interesting links themselves. There's a good reason for this - it's not trivial to implement; you have to think about Cookies and going through two web calls just to get a submission or comment to go through. It's annoying, and I've decided to make developers' lives easier by doing the annoying work myself and abstracting it away so you don't have to think about it again. It all starts with logging in.

The way HN operates in the browser is off of an HTTP Cookie. This Cookie is generated at login, and kept around for a pretty long time. Logging in on a different computer invalidates all Cookies for a user. Therefore, it's necessary to check if there's a cookie, and validate it before attempting to login. This is done automatically when the HNManager initializes itself using the method <code>startSession</code>. It will find the Cookie on the device and attempt to validate it. If it does check out, it will set the cookie to the <code>SessionCookie</code> parameter of the HNManager, as well as grab the correct HNUser so that the <code>SessionUser</code> property is filled in as well. If it doesn't find a Cookie, or the cookie is no longer valid, you will need to login the old-fashioned way using the following method. Make sure to check that a user is logged in first like so: 

```objc
// Check to make sure no user is logged in
if (![[HNManager sharedManager] userIsLoggedIn]) {
 // No user is logged in; attempt to login
 [[HNManager sharedManager] loginWithUsername:@"user" password:@"pass" completion:(HNUser *user){
   if (user) {
     // Login was successful!
   }
   else {
     // Login failed, handle the error
   }
 }];
}
```

Logging out just deletes the SessionCookie property and the SessionUser property from memory, as well as the actual cookie from <code>[NSHTTPCookieStorage sharedStorage]</code>, so you can't use them any more to make user-specific requests like submitting and commenting. Logging out is dead simple to implement.

```objc
[[HNManager sharedManager] logout];
```

Here's what the HNUser object looks like, for reference:

```objc
// HNUser.h

// Properties
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, assign) int Karma;
@property (nonatomic, assign) int Age;
@property (nonatomic, retain) NSString *AboutInfo;


// Methods
+(HNUser *)userFromHTML:(NSString *)html;
```

---------------------

## Submitting a New Post

Submitting a post is one of those crucial aspects of keeping the community going. Unfortunately, most of the good iOS/Mac clients don't feature this functionality - and so we're left with wallflowers, albeit beautiful, but still wallflowers. Not anymore though. On HackerNews, you can submit a link or a text post (Ask HN), and so we mimic this functionality inside of one single webservice call. To do a text post, just leave the link parameter nil. If both the link parameter AND the text parameter are filled in, the text will be ignored. If both are nil, then the completion block will fire with NO as the boolean value. Here's how you'd implement this:

```objc
// Submit a Link!
[[HNManager sharedManager] submitPostWithTitle:@"Hello World!" link:@"www.helloworld.com" text:nil completion:(BOOL success){
 if (success) {
  // Post was submitted
 }
 else {
  // Post was not submitted
 }
}];

// Submit a text post!
[[HNManager sharedManager] submitPostWithTitle:@"Hello World!" link:nil text:@"Hello World!" completion:(BOOL success){
 if (success) {
  // Post was submitted
 }
 else {
  // Post was not submitted
 }
}];

/////////////////

// This will use the LINK and not the text
[[HNManager sharedManager] submitPostWithTitle:@"Hello World!" link:@"www.helloworld.com" text:@"Hello World!" completion:(BOOL success){
 if (success) {
  // Post was submitted
 }
 else {
  // Post was not submitted
 }
}];

/////////////////

// These requests won't work!
[[HNManager sharedManager] submitPostWithTitle:@"Hello World!" link:nil text:nil completion:(BOOL success){
 //
}];

// Must have a title!
[[HNManager sharedManager] submitPostWithTitle:nil link:nil text:@"Hello World!" completion:(BOOL success){
 //
}];
```

---------------------

## Replying to a Post/Comment

Replying in HackerNews is the same regardless of the type of object you are replying to, post or another comment. This makes our lives a lot easier. Because of this, there's only one method to call when you want to reply to an object - you just feed it an HNPost or an HNComment and it figures out what to do from there. You must pass in an HNPost or HNComment as well as the text to comment with. If you don't do this, it will pass back a NO in the completion block, indicating failure. Here's the method:

```objc

[[HNManager sharedManager] replyToPostOrComment:(HNPost *)post withText:@"Comment to a post" completion:(BOOL success){
 if (success) {
  // Comment was submitted
 }
 else {
  // Comment failed submitting
 }
}];

// And of course, if you want to post a comment to a comment
[[HNManager sharedManager] replyToPostOrComment:(HNComment *)comment withText:@"Comment to a Comment" completion:(BOOL success){
 if (success) {
  // Comment was submitted
 }
 else {
  // Comment failed submitting
 }
}];

/////////////////

// This request won't work!
[[HNManager sharedManager] replyToPostOrComment:nil withText:@"Comment to a post" completion:(BOOL success){
 //
}];

// And neither will this one!
[[HNManager sharedManager] replyToPostOrComment:(HNComment *)comment withText:nil completion:(BOOL success){
 //
}];
```

---------------------

## Voting on a Post/Comment

There are a couple considerations to take when voting on a post. For a **Post**, you can only vote up. On **comments**, you can only vote up until you have >= 500 karma as a User. For this reason, this method might not let you vote up or down depending on your login status and the amount of karma you have on HN. If you get a NO in the completion block of this method - it did not successfuly let you vote.

```objc
[[HNManager sharedManager] voteOnPostOrComment:(HNPost *)post direction:VoteDirectionUp completion:(BOOL success){
 if (success) {
  // Voting worked!
 }
 else {
  // Voting was not successful!
 }
}];
```

---------------------

## Fetching all submissions for a User

Fetching posts for a user is kind of funky like fetching posts for the homepage based on a filter. The first 30 posts a user has can be achieved by navigating to the site like this: [https://news.ycombinator.com/submitted?id=pg](https://news.ycombinator.com/submitted?id=pg), but if you want any posts after this (assuming they have more than 30), you have to use an FNID again. For this reason, we're going to reuse a method from earlier to get any posts after the initial 30 and save the FNID as a property under HNManager called <code>userSubmissionUrlAddition</code>. Here's how you'd use this:

```objc
// Fetch the first 30 posts for a User
[[HNManager sharedManager] fetchSubmissionsForUser:@"pg" completion:(NSArray *posts){
 if (posts) {
    // Posts were successfuly retrieved
  }
  else {
    // No posts retrieved, handle the error
  }
}];

// Fetch posts 31 - n
[[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] userSubmissionUrlAddition] completion:(NSArray *posts){
  if (posts) {
    // Posts were successfuly retrieved
  }
  else {
    // No posts retrieved, handle the error
  }
}];
```

---------------------

## Auxiliary Methods

<code>HNManager</code> also handles a couple of different HN-related things, such as having the ability to keep track of which posts you have visited - allowing you to mark posts as read without implementing anything yourself. Here's a list of things you can do.

**Mark Posts As Read**

To mark a post as read, there is a dictionary inside of the HNManager that keeps track of everything for you. Using the manager, you can get a boolean on whether a post has been read or not, and also add an HNPost to the dictionary of read posts. Here's how you use this functionality:

```objc
// Methods
- (BOOL)hasUserReadPost:(HNPost *)post;
- (void)setMarkAsReadForPost:(HNPost *)post;

// Has User Read A Post?
BOOL hasRead = [[HNManager sharedManager] hasUserReadPost:(HNPost *)post];
if (hasRead) {
 // User has read the post.
}

// Add a post
[[HNManager sharedManager] setMarkAsReadForPost:post];
```

**Keep A Record of What A User has Voted On**

HackerNews is a little goofy about figuring out what can and cannot be voted on - so keeping track of this can be burdensome if you're rolling your own. However, in conjuction with the method to vote on a post/comment, if you get success back, you can throw the post/comment to this method which will handle what you've voted on.

```objc
// Methods
- (BOOL)hasVotedOnObject:(id)hnObject;
- (void)addHNObjectToVotedOnDictionary:(id)hnObject direction:(VoteDirection)direction;

// Find out if a post has been voted on
BOOL hasVoted = [[HNManager sharedManager] hasVotedOnObject:(HNPost *)post];
if (hasVoted) {
 // User has voted on the Post/Comment
}

// Add to the record
[[HNManager sharedManager] addHNObjectToVotedOnDictionary:(HNComment *)comment direction:VoteDirectionDown];
```

**Killing Web Requests**

Sometimes loading comments or posts can take a while, and you may want to navigate away in your app and stop the loading from continuing. To do this, you can make a simple method call that ends all web requests that are happening at the moment through HNManager.

```objc
[[HNManager sharedManager] cancelAllRequests];
```

---------------------

## Designing for the Future, and beyond!

Well basically, if you've dug in to the innards of how this works, you will have noticed that it relies very, very heavily on a parsing scheme to get the right info and make sesnse of it. As anyone who has every built something that scrapes knows, this is **not** a future-proof scheme. With that being said, I haven't seen HN change their innards. I think there are a few options to making this awesome and maintainble should HN do this, some of which are feasible and others probably less so.

* persuade PG to make a damn API
* use an online DB with the order of parsing and what parsing "tags" to look for so that if HN does change, nobody has to wait a week for Apple approval while their app crashes.
* write an API that scrapes HN every few minutes, but that costs money to provide volume to every app that may use it, and I'm broke.

**Features to Add**

I'm thinking of adding these features as things go along, but for v0.1, I wanted a bare-bones HN specific library.

* Editing A User - save their about/email basically.

---------------------

## Apps that use libHN

Here's a list of iOS/Mac apps that use libHN to provide sweet functionality. Use this library in your app? Open an issue and I'll add it to the list here:

* [News/YC](https://itunes.apple.com/us/app/news-yc/id592893508?mt=8) -- also on [GitHub](https://github.com/bennyguitar/News-YC---iPhone)

---------------------

## License

libHN is licensed under the standard MIT License.

**Copyright (C) 2013 by Benjamin Gordon**

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

---------------------
