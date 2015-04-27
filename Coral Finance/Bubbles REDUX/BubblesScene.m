//
//  BubblesScene.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/22/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "BubblesScene.h"

@implementation BubblesScene

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        for(int i=0; i<3; i++) {
            int offset = arc4random() % 20;
            int posNeg = arc4random() % 2 == 0 ? 1: -1;
            double scalar = ((double)offset)/20.0;
            double yScalar = ((double)offset)/60.0;
            CGRect circle = CGRectMake(location.x-40+(offset*posNeg), location.y-40+(offset*posNeg), 40.0*scalar, 40.0*scalar);
            SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
            shapeNode.path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
            shapeNode.fillColor = [SKColor clearColor];
            shapeNode.lineWidth = 4;
            shapeNode.antialiased = YES;
            [self addChild:shapeNode];
            SKAction *fadeOut = [SKAction moveByX:25.0*scalar y:0 duration:0.4+scalar];
            SKAction *fadeIn = [SKAction moveByX:-25.0*scalar y:0 duration:0.4+scalar];
            fadeIn.timingMode = SKActionTimingEaseInEaseOut;
            fadeOut.timingMode = SKActionTimingEaseInEaseOut;
            SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
            SKAction *initialX = [SKAction moveByX:(40.0*posNeg) y:20 duration:0.0+scalar];
            initialX.timingMode = SKActionTimingEaseOut;
            scalar = (scalar > 0.3) ? 0.3: scalar*0.5;
            SKAction *moveY = [SKAction moveByX:0 y:100 duration:0.5+yScalar];
            SKAction *moveYForever = [SKAction repeatActionForever:moveY];
            SKAction *pulseForever = [SKAction repeatActionForever:pulse];
            [shapeNode runAction:pulseForever];
            [shapeNode runAction:moveYForever];
            [shapeNode runAction:initialX];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    for (SKNode *child in self.children) {
        CGPoint positionInScene = [child.scene convertPoint:child.position fromNode:child.parent];
        BOOL isVisible = positionInScene.y - child.frame.size.height*2 < (self.view.frame.size.height);
        if(!isVisible) {
            [child removeFromParent];
        }
    }
}

@end
