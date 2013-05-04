News-YC---iPhone
================

The iPhone version of News/YC, a Hacker News reader and interactive iOS application. 

![ScreenShot](https://raw.github.com/bennyguitar/News-YC---iPhone/master/screens.png)

## About ##

News/YC is a front-page reader for Hacker News (http://news.ycombinator.com), a portal for interestingness regarding technology and building things. This app is free, and will forever remain free - and now, starting with version 2.0, is entirely open-sourced (please don't laugh at my code).

## The Code ##

The root ViewController, App Delegate, and HNSingleton are in the top-level directory, while every other class should be self-documented through the folders they are in (Webservice, Data Objects, Utilities, etc.).

#### Webservice.{h,m} ####

This class contains all web requests to the API, using a delegated system so ViewController can receive callbacks about the success or failure of each call - as well as the objects (posts/comments) returned.

```objc
-(void)getHomepage;
```

Fairly self-explanitory, this method hits the API and pulls the homepage back as Post objects, then calls the delegate method <code>-(void)didFetchPosts:(NSArray *)posts</code> to return objects back to ViewController. If no posts are retrieved, or there is a database/server error, <code>nil</code> is returned through the delegate method. ViewController checks off of this for exceptions and displays the posts accordingly.

```objc
-(void)getCommentsForPost:(Post *)post launchComments:(BOOL)launch;
```

This method returns an NSArray of Comment objects using the delegate method <code>-(void)didFetchComments:(NSArray *)comments forPostID:(NSString *)postID launchComments:(BOOL)launch</code> to callback to ViewController. The launchComments part of this method is for showing the commentsView in ViewController. If YES, this will animate commentsView coming up from the bottom, if NO, this is a pull-to-refresh case where the data was updated and only the table needs to be refreshed. This method will also return <code>nil</code> if there is a database/server retrieval problem so we can handle the exception accordingly.

#### Data Objects - Post.{h,m} and Comment.{h,m} ####

These classes make up the data model used by News/YC.

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

// Special Constructor
+(Post *)postFromDictionary:(NSDictionary *)dict;
```

```objc
@interface Comment : NSObject

// Properties
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSMutableAttributedString *attrText;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentID;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSDate *TimeCreated;
@property (nonatomic, retain) NSMutableArray *Children;
@property (nonatomic, retain) NSMutableArray *Links;
@property (nonatomic, assign) CommentType CellType;

// Constructor
+(Comment *)commentFromDictionary:(NSDictionary *)dict;
+(NSArray *)organizeComments:(NSArray *)comments topLevelID:(NSString *)topLevelID;
```

