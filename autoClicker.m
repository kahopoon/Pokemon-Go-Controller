#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

void postMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point) {
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        
        int x = [args integerForKey:@"x"];
        int y = [args integerForKey:@"y"];
        
        CGPoint pt;
        pt.x = x;
        pt.y = y;
        
        postMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, CGPointMake(x, y));
        usleep(100 * 1000);
        postMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, CGPointMake(x, y));
    }
    
    return 0;
}
