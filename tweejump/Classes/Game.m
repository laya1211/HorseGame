#import "Game.h"
#import "Main.h"
#import "Highscores.h"

@interface Game (Private)
- (void)initPlatforms;
- (void)initPlatform;
- (void)startGame;
- (void)resetPlatforms;
- (void)resetPlatform;
- (void)resetBird;
- (void)resetBonus;
- (void)step:(ccTime)dt;
- (void)jump;
- (void)showHighscores;
@end


@implementation Game

+ (CCScene *)scene:(int)inum
{
    CCScene *game = [CCScene node];
    
    Game *layer = [Game node];
    [game addChild:layer];

    
    int itime = inum % 2;
    
    if (itime == 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"马-BEGIN1.WAV"];
    }
    else
        [[SimpleAudioEngine sharedEngine] playEffect:@"马-BEGIN2.WAV"];

    return game;
}

+ (CCScene *)scene
{
    return [Game scene:0];
}

- (id)init {
//	NSLog(@"Game::init");
	
	if(![super init]) return nil;
	
	gameSuspended = YES;

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode *)[self getChildByTag:kSpriteManager];

	[self initPlatforms];
	
//	CCSprite *bird = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608,16,44,32)];
    CCSprite *bird = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608,410,58,47)];

	[batchNode addChild:bird z:4 tag:kBird];

	CCSprite *bonus;

	for(int i=0; i<kNumBonuses; i++) {
		bonus = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608+i*32,256,25,25)];
		[batchNode addChild:bonus z:4 tag:kBonusStartTag+i];
		bonus.visible = NO;
	}

//	LabelAtlas *scoreLabel = [LabelAtlas labelAtlasWithString:@"0" charMapFile:@"charmap.png" itemWidth:24 itemHeight:32 startCharMap:' '];
//	[self addChild:scoreLabel z:5 tag:kScoreLabel];
	
	CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFont.fnt"];
	[self addChild:scoreLabel z:5 tag:kScoreLabel];
    
//分数显示位置
	scoreLabel.position = ccp(160,50);

	[self schedule:@selector(step:)];
	
	self.isTouchEnabled = NO;
	self.isAccelerometerEnabled = YES;

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kFPS)];
	
	[self startGame];
	
    
    [self showAD:false];
    
    scoreSound = 1;
    
	return self;
}

- (void)dealloc {
//	NSLog(@"Game::dealloc");
	[super dealloc];
}

- (void)initPlatforms {
//	NSLog(@"initPlatforms");
	
	currentPlatformTag = kPlatformsStartTag;
	while(currentPlatformTag < kPlatformsStartTag + kNumPlatforms) {
		[self initPlatform];
		currentPlatformTag++;
	}
	
	[self resetPlatforms];
}


//石头
- (void)initPlatform {

	CGRect rect;
	switch(random()%2) {
//		case 0: rect = CGRectMake(608,64,102,36); break;
//        case 1: rect = CGRectMake(608,128,90,32); break;

		case 0: rect = CGRectMake(608,300,110,90); break;
        case 1: rect = CGRectMake(742,300,90,80); break;

	}

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *platform = [CCSprite spriteWithTexture:[batchNode texture] rect:rect];
	[batchNode addChild:platform z:3 tag:currentPlatformTag];
}

- (void)startGame {
//	NSLog(@"startGame");

	score = 0;
	
	[self resetClouds];
	[self resetPlatforms];
	[self resetBird];
	[self resetBonus];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	gameSuspended = NO;
}

- (void)resetPlatforms {
//	NSLog(@"resetPlatforms");
	
	currentPlatformY = -1;
	currentPlatformTag = kPlatformsStartTag;
    
//台阶高度间隔
//before
//	currentMaxPlatformStep = 60.0f;
//change
    currentMaxPlatformStep = 100.0f;

	currentBonusPlatformIndex = 0;
	currentBonusType = 0;
	platformCount = 0;

	while(currentPlatformTag < kPlatformsStartTag + kNumPlatforms) {
		[self resetPlatform];
		currentPlatformTag++;
	}
}

- (void)resetPlatform {
	
	if(currentPlatformY < 0)
    {
//        //before
//		currentPlatformY = 30.0f;
        //before
		currentPlatformY = 50.0f;

	} else {
		currentPlatformY += random() % (int)(currentMaxPlatformStep - kMinPlatformStep) + kMinPlatformStep;
		if(currentMaxPlatformStep < kMaxPlatformStep) {
			currentMaxPlatformStep += 0.5f;
		}
	}
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *platform = (CCSprite*)[batchNode getChildByTag:currentPlatformTag];
	
	if(random()%2==1) platform.scaleX = -1.0f;
	
	float x;
	CGSize size = platform.contentSize;
	if(currentPlatformY == 50.0f) {
		x = 160.0f;
	} else {
		x = random() % (320-(int)size.width) + size.width/2;
	}
	
	platform.position = ccp(x,currentPlatformY);
	platformCount++;
//	NSLog(@"platformCount = %d",platformCount);
	
	if(platformCount == currentBonusPlatformIndex) {
//		NSLog(@"platformCount == currentBonusPlatformIndex");
		CCSprite *bonus = (CCSprite*)[batchNode getChildByTag:kBonusStartTag+currentBonusType];
		bonus.position = ccp(x,currentPlatformY+50);
		bonus.visible = YES;
	}
}

- (void)resetBird {
//	NSLog(@"resetBird");

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *bird = (CCSprite*)[batchNode getChildByTag:kBird];
	
	bird_pos.x = 160;
	bird_pos.y = 160;
	bird.position = bird_pos;
	
	bird_vel.x = 0;
	bird_vel.y = 0;
	
	bird_acc.x = 0;
	bird_acc.y = -550.0f;
	
	birdLookingRight = YES;
	bird.scaleX = 1.0f;
}

- (void)resetBonus {
//	NSLog(@"resetBonus");
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *bonus = (CCSprite*)[batchNode getChildByTag:kBonusStartTag+currentBonusType];
	bonus.visible = NO;
	currentBonusPlatformIndex += random() % (kMaxBonusStep - kMinBonusStep) + kMinBonusStep;
	if(score < 10000) {
		currentBonusType = 0;
	} else if(score < 50000) {
		currentBonusType = random() % 2;
	} else if(score < 100000) {
		currentBonusType = random() % 3;
	} else {
		currentBonusType = random() % 2 + 2;
	}
}

- (void)step:(ccTime)dt {
//	NSLog(@"Game::step");

	[super step:dt];
	
	if(gameSuspended) return;

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *bird = (CCSprite*)[batchNode getChildByTag:kBird];
	
	bird_pos.x += bird_vel.x * dt;
	
	if(bird_vel.x < -30.0f && birdLookingRight) {
		birdLookingRight = NO;
		bird.scaleX = -1.0f;
	} else if (bird_vel.x > 30.0f && !birdLookingRight) {
		birdLookingRight = YES;
		bird.scaleX = 1.0f;
	}

	CGSize bird_size = bird.contentSize;
	float max_x = 320-bird_size.width/2;
	float min_x = 0+bird_size.width/2;
	
	if(bird_pos.x>max_x) bird_pos.x = max_x;
	if(bird_pos.x<min_x) bird_pos.x = min_x;
	
	bird_vel.y += bird_acc.y * dt;
	bird_pos.y += bird_vel.y * dt;
	
	CCSprite *bonus = (CCSprite*)[batchNode getChildByTag:kBonusStartTag+currentBonusType];
	if(bonus.visible)
    {
		CGPoint bonus_pos = bonus.position;
		float range = 20.0f;
		if(bird_pos.x > bonus_pos.x - range &&
		   bird_pos.x < bonus_pos.x + range &&
		   bird_pos.y > bonus_pos.y - range &&
		   bird_pos.y < bonus_pos.y + range ) {
			switch(currentBonusType) {
				case kBonus5:   score += 5000;   break;
				case kBonus10:  score += 10000;  break;
				case kBonus50:  score += 50000;  break;
				case kBonus100: score += 100000; break;
			}
			NSString *scoreStr = [NSString stringWithFormat:@"%d",score];
			CCLabelBMFont *scoreLabel = (CCLabelBMFont*)[self getChildByTag:kScoreLabel];
			[scoreLabel setString:scoreStr];
			id a1 = [CCScaleTo actionWithDuration:0.2f scaleX:1.5f scaleY:0.8f];
			id a2 = [CCScaleTo actionWithDuration:0.2f scaleX:1.0f scaleY:1.0f];
			id a3 = [CCSequence actions:a1,a2,a1,a2,a1,a2,nil];
			[scoreLabel runAction:a3];
			[self resetBonus];
		}
	}
	
//	int t;
	
	if(bird_vel.y < 0) {
		
//		t = kPlatformsStartTag;
		for(int t= kPlatformsStartTag; t < kPlatformsStartTag + kNumPlatforms; t++) {
			CCSprite *platform = (CCSprite*)[batchNode getChildByTag:t];

			CGSize platform_size = platform.contentSize;
			CGPoint platform_pos = platform.position;
			
			max_x = platform_pos.x - platform_size.width/2 - 10;
			min_x = platform_pos.x + platform_size.width/2 + 10;
			float min_y = platform_pos.y + (platform_size.height+bird_size.height)/2 - kPlatformTopPadding;
			
			if(bird_pos.x > max_x &&
			   bird_pos.x < min_x &&
			   bird_pos.y > platform_pos.y &&
			   bird_pos.y < min_y) {
				[self jump];
			}
		}
		
        //超出屏幕，游戏结束
//		if(bird_pos.y < -bird_size.height/2) {
//			[self showHighscores];
//		}
        if(bird_pos.y < 0) {
			[self showHighscores];
		}

		
	} else if(bird_pos.y > 240) {
		
		float delta = bird_pos.y - 240;
		bird_pos.y = 240;

		currentPlatformY -= delta;
		
//		t = kCloudsStartTag;
		for(int t= kCloudsStartTag; t < kCloudsStartTag + kNumClouds; t++) {
			CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:t];
			CGPoint pos = cloud.position;
			pos.y -= delta * cloud.scaleY * 0.8f;
			if(pos.y < -cloud.contentSize.height/2) {
				currentCloudTag = t;
				[self resetCloud];
			} else {
				cloud.position = pos;
			}
		}
		
//		t = kPlatformsStartTag;
		for(int t= kPlatformsStartTag; t < kPlatformsStartTag + kNumPlatforms; t++) {
			CCSprite *platform = (CCSprite*)[batchNode getChildByTag:t];
			CGPoint pos = platform.position;
			pos = ccp(pos.x,pos.y-delta);
			if(pos.y < -platform.contentSize.height/2) {
				currentPlatformTag = t;
				[self resetPlatform];
			} else {
				platform.position = pos;
			}
		}
		
		if(bonus.visible) {
			CGPoint pos = bonus.position;
			pos.y -= delta;
			if(pos.y < -bonus.contentSize.height/2) {
				[self resetBonus];
			} else {
				bonus.position = pos;
			}
		}
		
		score += (int)delta;
		NSString *scoreStr = [NSString stringWithFormat:@"%d",score];

		CCLabelBMFont *scoreLabel = (CCLabelBMFont*)[self getChildByTag:kScoreLabel];
		[scoreLabel setString:scoreStr];
        
        [self playScoreSound];
	}
	
	bird.position = bird_pos;
}

- (void)playStepSound
{
    int i=score % 5+1;
    
    NSString *strSound = [NSString stringWithFormat:@"step%d.wav",i];
    [[SimpleAudioEngine sharedEngine] playEffect:strSound];
    
}

- (void)playScoreSound
{
    int sscore = scoreSound * 1000;
    
    //达到1000的倍数，播放声音
    if (score >= sscore) {
        
        if (scoreSound %2 == 1) {
             [[SimpleAudioEngine sharedEngine] playEffect:@"马-BEGIN1.WAV"];
        }
        else
            [[SimpleAudioEngine sharedEngine] playEffect:@"马-BEGIN2.WAV"];
        

        scoreSound = score /1000 + 1 ;
        
        
        NSString *scoreStr = [NSString stringWithFormat:@"%d",score];
        CCLabelBMFont *scoreLabel = (CCLabelBMFont*)[self getChildByTag:kScoreLabel];
        [scoreLabel setString:scoreStr];
        id a1 = [CCScaleTo actionWithDuration:0.2f scaleX:1.5f scaleY:0.8f];
        id a2 = [CCScaleTo actionWithDuration:0.2f scaleX:1.0f scaleY:1.0f];
        id a3 = [CCSequence actions:a1,a2,a1,a2,a1,a2,nil];
        [scoreLabel runAction:a3];
        [self resetBonus];
        
    }
    
//    switch (scoreSound) {
//        case 0:
//            sscore = 1000;
//            break;
//            
//        case 1:
//            sscore = 2000;
//            break;
//            
//        case 2:
//            sscore = 3000;
//            break;
//        case 3:
//            sscore = 5000;
//            break;
//        case 4:
//            sscore = 8000;
//            break;
//        case 5:
//            sscore = 10000;
//            break;
//            
//        default:
//            break;
//    }
}

- (void)jump {
	bird_vel.y = 350.0f + fabsf(bird_vel.x);
    
    [self playStepSound];
}



- (void)showHighscores {
//	NSLog(@"showHighscores");
	gameSuspended = YES;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
//	NSLog(@"score = %d",score);
	[[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:1 scene:[Highscores sceneWithScore:score] withColor:ccWHITE]];
}

//- (BOOL)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
//	NSLog(@"ccTouchesEnded");
//
////	[self showHighscores];
//
////	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
////	AtlasSprite *bonus = (AtlasSprite*)[spriteManager getChildByTag:kBonus];
////	bonus.position = ccp(160,30);
////	bonus.visible = !bonus.visible;
//
////	BitmapFontAtlas *scoreLabel = (BitmapFontAtlas*)[self getChildByTag:kScoreLabel];
////	id a1 = [ScaleTo actionWithDuration:0.2f scaleX:1.5f scaleY:0.8f];
////	id a2 = [ScaleTo actionWithDuration:0.2f scaleX:1.0f scaleY:1.0f];
////	id a3 = [Sequence actions:a1,a2,a1,a2,a1,a2,nil];
////	[scoreLabel runAction:a3];
//
//	AtlasSpriteManager *spriteManager = (AtlasSpriteManager*)[self getChildByTag:kSpriteManager];
//	AtlasSprite *platform = (AtlasSprite*)[spriteManager getChildByTag:kPlatformsStartTag+5];
//	id a1 = [MoveBy actionWithDuration:2 position:ccp(100,0)];
//	id a2 = [MoveBy actionWithDuration:2 position:ccp(-200,0)];
//	id a3 = [Sequence actions:a1,a2,a1,nil];
//	id a4 = [RepeatForever actionWithAction:a3];
//	[platform runAction:a4];
//	
//	return kEventHandled;
//}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	if(gameSuspended) return;
	float accel_filter = 0.1f;
	bird_vel.x = bird_vel.x * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	NSLog(@"alertView:clickedButtonAtIndex: %i",buttonIndex);

	if(buttonIndex == 0) {
		[self startGame];
	} else {
		[self startGame];
	}
}

@end
