News/YC for iPhone
================

The iPhone version of News/YC, a Hacker News reader and interactive iOS application. 

![ScreenShot](https://raw.github.com/bennyguitar/News-YC---iPhone/master/screens.png)

## About ##

News/YC is a front-page reader for Hacker News (http://news.ycombinator.com), a portal for interestingness regarding technology and building things. This app is free, and will forever remain free - and now, starting with version 1.2, is entirely open-sourced (please don't laugh at my code). The app can be found on the iOS App Store here: https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8

--------------------
## The Code ##

The root ViewController, App Delegate, and HNSingleton are in the top-level directory, while every other class should be self-documented through the folders they are in (Webservice, Data Objects, Utilities, etc.). There are a number of features that are in this code-base that aren't in the public release version (1.2) that is on the iOS App Store right now. I've tried to document these features in sub-sections labeled **Version 2**, and are currently in-progress (things like logging in and voting). Feel free to help out on these features and launch the best HN reader for iOS!

* Current iOS SDK: 6.0+
* Current AppStore Version: 1.2
* <a href="https://www.cisimple.com/jobs/kh1isdaal986n3ip9"><img src='https://www.cisimple.com/jobs/kh1isdaal986n3ip9/build_status.png'/></a>

--------------------
#### Webservice.{h,m} ####

This class contains all web requests to the API, using a delegated system so ViewController can receive callbacks about the success or failure of each call - as well as the objects (posts/comments) returned.

```objc
-(void)getHomepageWithFilter:(NSString *)filter success:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure;
```

Fairly self-explanatory, this method hits the API and pulls the homepage back as Post objects, then calls the success block to return objects back to ViewController. If no posts are retrieved, or there is a database/server error, the failure block is called. The filter parameter is passed in based on a FilterType enum that is for fetching the Top/Ask/New/Jobs/Best posts.

```objc
-(void)getHomepageFromFnid:(NSString *)fnid withSuccess:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure;
```

As you scroll down the homepage, once you are 3 cells from the bottom, it attempts to load the next batch of posts, or what is equivalent to hitting "more" at the bottom of the HN homepage. When any GetHomepage method returns, and Posts are created, the FNID that tells the server where to get posts next is kept in the Singleton. This is passed in to this method as a parameter, and when it returns, more Post objects are generated (as well as a new FNID) and returned in the success block.

```objc
-(void)getCommentsForPost:(Post *)post success:(GetCommentsSuccessBlock)success failure:(GetCommentsFailureBlock)failure;
```

This method returns an NSArray of Comment objects, for a given Post object, in the success block if it works.

**For Version 2**

```objc
-(void)loginWithUsername:(NSString *)user password:(NSString *)pass;
```

This method handles logging in and returns a User object using the delegate method <code>-(void)didLoginWithUser:(User *)user</code> to call back to whatever ViewController implements and makes the call. I'm thinking about putting this method in the HNSingleton class to keep an app-wide scope on the login status (since everything is handled asynchronously) and using NSNotificationCenter when a login/logout occurs.

```objc
-(void)voteUp:(BOOL)up forObject:(id)HNObject;
```

This method handles voting for objects. I'm currently working on adding in the UI to handle voting/commenting on stories, and this method will take control of voting on any object (HNObject is just a Post or Comment). The callback to this delegate will be a BOOL, indicating a successful vote or not. However, I don't plan on doing anything UI-wise specifically that will alert the user that it failed (may just be too much information), though I do plan on alerting them if the cookie is bad so they can re-login and attempt again.

--------------------
#### Data Objects - Post.{h,m} and Comment.{h,m} ####

These classes make up the data model used by News/YC. Both Post and Comment contain special constructor methods based on the JSON objects that return from <code>Webservice.{h,m}</code> calls - going from NSDictionary to objects. Comment has an NSMutableAttributedString property, <code>attrText</code> that isn't used right now, but there are plans in the future to use this to style up comments (more on that in the *Things to Come* section).

```objc
@interface Post : NSObject

// Properties
@property (nonatomic,retain) NSString *Username;
@property (nonatomic, retain) NSString *URLString;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, assign) int Points;
@property (nonatomic, assign) int CommentCount;
@property (nonatomic, retain) NSString *PostID;
@property (nonatomic, assign) BOOL HasRead;
@property (nonatomic, retain) NSDate *TimeCreated;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *hnPostID;
@property (nonatomic, assign) BOOL isOpenForActions;
@property (nonatomic, assign) BOOL isJobPost;
@property (nonatomic, assign) BOOL isAskHN;

+ (NSArray *)parsedFrontPagePostsFromHTML:(NSString *)htmlString;
```

```objc
@interface Comment : NSObject

// Properties
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSMutableAttributedString *attrText;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentID;
@property (nonatomic, retain) NSString *hnCommentID;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, retain) NSString *TimeAgoString;
@property (nonatomic, retain) NSString *ReplyURL;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSDate *TimeCreated;
@property (nonatomic, retain) NSMutableArray *Children;
@property (nonatomic, retain) NSMutableArray *Links;
@property (nonatomic, assign) CommentType CellType;
@property (nonatomic, assign) BOOL isAskHN;
@property (nonatomic, assign) BOOL isHNJobs;

+(NSArray *)commentsFromHTML:(NSString *)html askHN:(BOOL)askHN jobs:(BOOL)HNJobs;
```

**For Version 2.0**

I have included a User.{h,m} object with the intention of adding user-management functionality as well as submitting/commenting/voting.

```objc
@interface User : NSObject

// Properties
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, assign) int Karma;
@property (nonatomic, assign) int Age;
@property (nonatomic, retain) NSString *AboutInfo;
```

--------------------
#### HNSingleton.{h,m} ####

This class contains a few properties that manage things on an app-wide scope. Included is an NSDictionary for keeping track of which articles have been read (though I'm thinking about adding this to the NSUserDefaults so it will always stay with the app), and the remnants of version 1.1.1 when I was using a different API to filter the homepage by Top/New/Ask (which I'd love to reincorporate again). HNSingleton incorporates a couple methods to change the theme colors and set the SessionKey (more under the break).

**As of Version 2.0**: It now includes the CurrentFNID property that grabs the next set of homepage posts in batches.

```objc
@interface HNSingleton : NSObject

// Properties
@property (nonatomic, retain) NSMutableDictionary *hasReadThisArticleDict;
@property (nonatomic, retain) NSMutableDictionary *votedForDictionary;
@property (nonatomic, retain) NSMutableDictionary *themeDict;
@property (nonatomic, assign) enum fType filter;
@property (nonatomic, retain) NSHTTPCookie *SessionCookie;
@property (nonatomic, retain) User *User;
@property (nonatomic, retain) NSString *CurrentFNID;

// Methods
-(void)changeTheme;
-(void)setSession;
-(void)loginWithUser:(NSString *)user password:(NSString *)pass;
-(void)logout;
```

**For Version 2.0**

This class also includes a NSHTTPCookie object, <code>SessionKey</code> for keeping track of user-authenticated actions such as submitting or voting. A successful login adds the cookie to the persistent cache of cookies that iOS implements device-wide. A check for the cookie inside AppDelegate's launching method adds it to the Singleton. Every authentication-important Webservice call will attach this cookie to the HTTPHeaders before the request is sent.

Loggin In/Out is another new feature set for a v2.0 release. This HNSingleton class also keeps track of the current User object associated with a login and all of the login functionality. From anywhere in the app, if a login is necessary - a call to <code>[[HNSingleton sharedHNSingleton] loginWithUser:(NSString *)user password:(NSString *)pass</code> is made.

--------------------
## API ##

News/YC uses the only officially sanctioned API that Hacker News approves of: http://hnsearch.com/api. The API calls made by this app are slightly tricky. For the front-page posts, a call is made to http://hnsearch.com/bigrss and then the resulting xml is parsed to grab the unique IDs from each post. Those are then sent as a request to the actual API to get the posts. The comments, unfortunately, return as basically a totally unordered set. I create a linked list out of those, and then I turn it into a flat array based on the nested nature of the comments - so UITableView will render correctly. All of the Comment trickery is done in <code>Comment.m</code>.

--------------------
## 3rd Party Libraries ##

News/YC uses the following third party libraries:

* IIViewDeck - https://github.com/Inferis/ViewDeck
* MYJsonWebservice - https://github.com/MatthewYork/JSON-Webservice-Template
* KGStatusBar - https://github.com/kevingibbon/KGStatusBar

--------------------
## Things to Come ##

For subsequent versions, I'd like to see a couple things happen to make this app awesome.

**Features**

* Logging In
* Voting
* Submitting
* Commenting
* Viewing Ask HN / Newest Posts

Having a beautiful and easy-to-use user management system is what this app needs. I've included a spot for this already with the right ViewDeck, but have not designed anything. Ideally, a user would login by swiping open the right side and entering their credentials. Then that side would show their karma, about me info (changeable perhaps), date created, and other useful user information. The only problem is that there is zero API support of this functionality and there probably never will be, especially since it seems like PG doesn't really approve of external APIs and brings the hammer down with rate-limiters. That said, I believe that this functionality could be implemented via client-side scraping rather than doing it on a server and serving up JSON for anyone to grab. Of course submitting, commenting and voting would follow from the ability to login.

I'm hoping to basically include only one more class <code>User.{h,m}</code> and all calls/scraping be done in Webservice. I may implement the HNKit (https://github.com/Xuzz/HNKit) code to do this, but there isn't much documentation on it, it doesn't look like it's in ARC, and it seems fairly convoluted.

**In Code**
* Comment labels using NSAttributedString (for < html > tags)
* Cleaned up a little bit / better documentation

The API returns comment text with different HTML tags inside it including <code>< p >,< i >, and < code ></code> that would be very cool to format in via NSAttributedString. I'm already turning the <code>< p ></code> tags into new lines, but italics are used for emphasis quite a bit in HN comments, and I'd like to have that in here as well.

--------------------
## License ##

This repository is licensed under the standard MIT license. Any third party code that appears in this repository is licensed under the terms the original author laid out and does not transfer to my licensure. Feel free to use whatever you'd like from this.

