## SwipeModifier
SwiftUI is a wonderful API that allows you to get mouse and touch actions for both macOS applications and iOS applications. There is just one thing missing that people keep asking for over and over:

>How do I detect the scrollWheel?

After going over multiple iterations over the years (I've found some that are over a decade old!) I finally decided that none of the solutions were good enough. Let me detail a few of the issues:

1. Overly complicated. Yes, rather than show the bare bones, many went out of their way to show they know the guts of Swift. I was very impressed. I don't profess to be that smart. I just needed something that worked.

2. Memory leaks. Some of the solutions were so brief, that the "solution" leaked memory--not what you really want. 🤷

3. Incomplete. Sure, I like to write code, but the amount of support code to get somethiing working, while not difficult to write, didn't really represent a solution. Either it was overly verbose and, well, wrong, or it was succint and, well, wrong.

### View Modifiers To the rescue!

What I wanted was something that looked much like Apple's view modifier for detecting mouse movement:

    DragGesture()
        .onChanged { value in
            /* do something */
        }

Well, this was more complex than I needed so I modeled it a little after the `.onTapGesture` which was a little more understandable. Since I needed the other information, I made it look somethiing like the following:

    .onSwipe { event in
        switch event.direction {
            case .up:
                /* do some code */
            case .down:
                /* do some code */
            case .left:
                /* do some code */
            case .right:
                /* do some code */
        }
    }

Easy peasy, right?

Peasy? Yes. Easy? Not so much. The amount of verbiage and videos on how to make a **simple** modifier exist (how to change text to red) but nothing like the above. In the end I looked at Apple's header and went 💡 Oh! That's how you do it!

### But wait, there's more

Let's say you want to move left and up or down and right? Hard to do with just up and down, right? I've 
got you covered with the new compass directions! This makes things much simpler so you can write the
code in a way that makes sense! 

    .onSwipe { event in
        switch event.compass {
            case .north:
                print("north")
            case .south:
                print("south")
            case .east:
                print("east")
            case .west:
                print("west")
            case .southEast:
                print("southeast")
            case .southWest:
                print("southwest")
            case .northWest:
                print("northwest")
            case .northEast:
                print("northeast")
            case .none:
                print("none")
        }
    }

### Just give me the code!

Okay, okay, you will find the code with an example of how to use the modifier. The modifier is named onSwipe (I know, it took me a while to come up with the name). Feel free to name it whatever you want (but please don't delete the copyright notice... it did take me a few days to get it right).

I've run `profile` on it so if you find any leaks, they're in your code 😅 If you **do** find bugs, please let me know. I'm using this code and I don't want bugs either.

### Final Thoughts

The biggest problem in all of this was finding the memory leaks. The `.onDisappear` was important to solving this. Please do not delete the `.onDisappear` or your code will start leakiing.

Notice that this uses `.onContinousHover` which should not interfere with any other usage of `.onContinousHover`-- this is the one modifier I have checked.

Good luck and have fun with it!
