![banner](resources/gh/banner.png)

## About

**News/YC** is an iOS app that tries to do one thing, give you [Hacker News](https://news.ycombinator.com) and get the hell out of the way. If the app isn't doing something you feel it should, or if you think there's an easier way to get an action accomplished - open up an Issue! I want your feedback. This app was made by me, for my usage, so it probably won't line up with everybody's tastes and there is probably a huge group of people with better taste than me. Feel free to be vocal - it's the only way to make this app the best!

This app **does not** use the new [HackerNews API](https://github.com/HackerNews/API), but instead relies on [libHN](https://github.com/bennyguitar/libHN) for the interface to HN content.

**App Store**

* 3.0
* Swift

## Table of Contents

* [General Architecture](#general-architecture)
  * [HNNavigationBrain](#hnnavigationbrain)
  * [HNTheme](#hntheme)
  * [View Controllers](#view-controllers)
* [What's Next?](#whats-next)

## General Architecture

This app is built in Swift, but is really a port of an existing app with a little bit clearer design and modularity of components. There are a few architecture decisions I made to make some things easier that may or may not be defacto architecture or MVC considerations. The first of which is...

## HNNavigationBrain

This class is literally the arbiter for all navigation related activities. I made this class with the idea that I shouldn't have to constantly defer navigation-related logic up through a chain to meet a UIViewController which then actually does it. That's too much of a chain, and honestly too much of a hassle. I wanted the system to be slightly knowledgable about itself. I wanted to be able to navigate at any time I want.

Enter the **Brain**.

The navigation brain works by making every navigable View Controller a subclass of `HNViewController` which handles a lot of boilerplate logic like building the navigation bar and responding to theme changes, etc. The biggest thing this view controller does is listen for navigation notifications, and responding if they are valid. `HNNavigationBrain` initiates navigation by a bunch of possible methods (navigate to Posts, navigate to comments for Post, etc) and passes a newly instantiated HNViewController instance through the `NSNotificationCenter` to the top-most view controller in the UINavigationController's stack.

What this effectively means, is that anything can initiate navigation. All views, models, and controllers have this functionality thanks to the brain. This scheme is not without possible problems, however, but we try to minimize these as much as possible. Navigation events are fairly predictable reactions to button presses, so we don't have to worry so much about different classes calling navigation notifications at the same time. But it is beneficial to think about this as you commit and contribute to the project.

It's fairly easy to use the navigation brain as well:

```swift
HNNavigationBrain.navigateToComments(somePost)
```

## HNTheme

`HNTheme.currentTheme()` acts as the main interface for all them and color related functionality of the app. The `currentTheme()` singleton instance determines how all UI color schemes are assigned, and handles the notifications blasted out when the theme is changed. All HNViewControllers and their subclasses override the `resetUI()` method to reset after a theme change.

Currently there are four themes in the app, two light (Day and Minima) and two dark (Night and SpaceOne). Since I'm an art guy myself, you can bet your butt there will be more themes and theme packs later.

## View Controllers

As mentioned earlier, all navigable view controllers in the app are subclasses of `HNViewController` - but those don't account for all view controllers in the app.

**HNViewController subclassed**

* HNPostsViewController
* HNCommentsViewController
* HNWebViewController

**UIViewController subclassed**

* HNSubmissionViewController
* HNNavigationViewController

## What's Next?

Apart from library changes here and there whenever YC starts messing with the site site's HTML markup, here's the list of functionality I'd like to add:

* Nesting Comments
* Find text in comment strings
* More themes!
