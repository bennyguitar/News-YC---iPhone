News/YC for iPhone
================

The iPhone version of News/YC, a Hacker News reader and interactive iOS application. 

![ScreenShot](https://raw.github.com/bennyguitar/News-YC---iPhone/master/screens.png)

## About ##

News/YC is a reader for Hacker News (http://news.ycombinator.com), a portal for interestingness regarding technology, entrepreneurship, and building things. This app is free, and will forever remain free - and now, starting with version 1.2, is entirely open-sourced (please don't laugh at my code). The app can be found on the iOS App Store here: https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8

--------------------
## Table of Contents ##

* [The Code](#the-code)
  * [libHN](#libhn)
  * [Posts View Controller](#posts-view-controller)
  * [Comments View Controller](#comments-view-controller)
  * [Links View Controller](#links-view-controller)
  * [Submit Post/Comment View Controller](#submit-hn-view-controller)
  * [Left Navigation](#left-navigation)
  * [Helpers](#helpers)
  * [3rd Party Libraries](#3rd-party-libraries)
* [What's To Come](#whats-to-come)
* [License](#license)
  
--------------------
## The Code

**News/YC** is the sleekest HackerNews reader and now contribution portal on the iOS App Store. This codebase has been open sourced since version 1.2 of the app, and will remain online for people to learn and contribute to creating the sleekest app even sleeker. After version 2, I have subsequently cleaned up and refactored most of the code to be cleaner, and much more maintainable for future design and feature implementation. Instead of throwing all actions in one View Controller, specific actions and views are broken up into multiple View Controllers, with a much larger focus and reliance on the UINavigationController scheme (it's finally looking better for iOS 7).

* Current iOS SDK: 6.0+
* Current AppStore Version: 2.1

--------------------
## libHN

I got tired of having a HackerNews API engine that was totally dependent on my existing App structure, and so decided to write my own library, separate of the app, that I would then hook into for Version 2.1. This library is also on Github, and is called [libHN](https://github.com/bennyguitar/libHN). It handles all of the web calls, and the user management (including cookies necessary for doing user-specific actions). All of libHN is documented on its Github page, and you can read through that code to see what's happening and where.

--------------------
## Posts View Controller

<code>PostsViewController.{h,m}</code> acts as the root View Controller for the app, and functions to display any type of data that is a collection of submissions. So, whenever you want to see the top posts right now, or the newest posts, or even your posts as a logged in user, you use PostsViewController to display them. This class is mostly just a TableView and some auxiliary methods that handle actions and events that pertain to posts and the displaying of posts.

**Loading posts by batch**

Basically, libHN loads posts by batches. If you go to [Hacker News](https://news.ycombinator.com) you will see that there are 30 posts and then a link to More at the bottom. If you click more, it will go to posts 31-60 with another link for More as well. libHN follows this structure, and thus only loads the initial 30 posts when you initialize PostsViewController through the <code>loadHomepage</code> method. To provide a seamless experience, in the <code>scrollViewDidScroll</code> method, I am checking for being close to the end of the table (really the third from the bottom post), and then loading the next batch. After the next batch is loaded it appends that array of posts onto the main <code>self.Posts</code> property and reloads the table. There is also a property called <code>isLoadingFromFNID</code> that basically acts as a lock to prevent slamming the HN server for the next batch of posts every time the scroll view is scrolling near that limit.

--------------------
## Comments View Controller

All of the code for viewing and interacting with comments happens in <code>CommentsViewController.{h,m}</code> and is initialized using the <code>initWithNibName:bundle:post:</code> method that takes in an <code>HNPost</code> object. Comments are only loaded through one method, which acts on the post you initialized the controller with. Interactions with the comment cell are handled by a couple of delegates that pass information back up to the ViewController to handle.

**TTTAttributedLabelDelegate** 

This delegate handles clicking on links inside of comments. When a user taps on a link, it grabs the URL and passes that information to <code>LinksViewController</code> to show that information in a WebView.

**CommentCellDelgate**

Each comment cell has an auxiliary view that shows/hides on tap. Inside of this auxiliary view is a set of four buttons: share comment, reply to comment, upvote and downvote the comment. Each of these actions is also tied to a delegate method that makes it easy to do each related action on the comment. The four delegate methods are:

```objc
- (void)didClickShareCommentAtIndex:(int)index;
- (void)didClickReplyToCommentAtIndex:(int)index;
- (void)didClickUpvoteCommentAtIndex:(int)index;
- (void)didClickDownvoteCommentAtIndex:(int)index;
```

**Adding a newly submitted comment to the Table**

After a user submits a new comment to either the parent post of the list of comments, or to a specific comment, the newly submitted comment is added in the correct place to the tableview to simulate adding in-line and provide a little bit of visual feedback for doing something successfully. The method that handles this is <code>- (void)addSubmittedCommentNotification:(NSNotification *)notification</code> and is called from the NSNotificationCenter.

--------------------
## Links View Controller

All of the links (either from a Submission or any link inside of Comment text) are sent to and displayed through the <code>LinksViewController</code>. This class also handles sharing the link to Facebook, Twitter, Chrome, Safari or any other app extensions that a user may have on his/her device for sharing. This logic is handled by the stock Apple iOS SDK UI elements for <code>UIActivityViewController</code>.

--------------------
## Submit HN View Controller

<code>SubmitHNViewController.{h,m}</code> handles all of the logic and presentation details for submitting a new post or a reply to either a post or a comment. This controller also includes several UI methods for making a better experience (mostly regarding the UITextViews and keyboards hiding/showing and resize methods). After successful submission of a comment, this class will post a notification that is intercepted and acted upon by <code>CommentsViewController</code> to display the comment in-line.

--------------------
## Left Navigation

The navigation scheme of this app is based off of the sliding menu paradigm of many popular apps for a couple of reasons. Despite Apple's best intentions to add swipe from bezel control for navigating amongst the UINavigationController View Controllers, I believe that having a plethora of navigation links and views on the left is the best way for keeping a clean main interface (ie having no tab bar taking up an additional 44 pixels on the bottom). Also, having a quick way to see different-but-related information without navigating away from what you're doing/reading is very beneficial to the end user. For those reasons I am going to stick with a swipe from left scheme to reveal the main navigation for the app.

Inside of this view controller are several different sub-actions that control the behavior of the entire app. All of the front page filtering happens inside of this View Controller - which controls the types of posts you can see in <code>PostsViewController</code>. If you have purchased the Pro upgrade, you can login, logout, and view your submissions inside of this controller. If you haven't purchased the upgrade, then you can navigate to the page to buy the upgrade. From here you can also share the app (and not a comment or a link), and view the credits (really just a plug for myself).

All of the specific actions are handled through delegation by the respective UITableViewCell subclasses that exist.

--------------------
## Helpers

There are a few helper methods that are used app-wide that build the navigation bar and add UIActivityIndicatorViews in the correct locations inside of the navigation bar for various actions. Any time a web call is made, a UIActivityIndicatorView is added to the navigation bar - and removed upon completion. Any time a ViewController loads, the navigation bar is built with either the hamburger menu button or to let the UINavigationController handle putting a back button there. It also adds any right menu buttons for upvoting, adding a comment/post or sharing a link.

--------------------
## 3rd Party Libraries ##

News/YC uses the following third party libraries:

* IIViewDeck - https://github.com/Inferis/ViewDeck
* MYJsonWebservice - https://github.com/MatthewYork/JSON-Webservice-Template
* KGStatusBar - https://github.com/kevingibbon/KGStatusBar

--------------------
## What's To Come

The first thing on my list for new features is a CoreData store for saving comments, posts and submissions to the app itself for future retrieval.

--------------------
## License 

This repository is licensed under the standard MIT license. Any third party code that appears in this repository is licensed under the terms the original author laid out and does not transfer to my licensure. Feel free to use whatever you'd like from this.

