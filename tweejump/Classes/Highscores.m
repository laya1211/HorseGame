#import "Highscores.h"
#import "Main.h"
#import "Game.h"

@interface Highscores (Private)
- (void)loadCurrentPlayer;
- (void)loadHighscores;
- (void)updateHighscores;
- (void)saveCurrentPlayer;
- (void)saveHighscores;
- (void)button1Callback:(id)sender;
- (void)button2Callback:(id)sender;
@end


@implementation Highscores

+ (CCScene *)sceneWithScore:(int)lastScore
{
    CCScene *game = [CCScene node];
    
    Highscores *layer = [[[Highscores alloc] initWithScore:lastScore] autorelease];
    [game addChild:layer];
    
    return game;
}

- (id)initWithScore:(int)lastScore {
//	NSLog(@"Highscores::init");
	
	if(![super init]) return nil;

//	NSLog(@"lastScore = %d",lastScore);
	
	currentScore = lastScore;

//	NSLog(@"currentScore = %d",currentScore);
	
	[self loadCurrentPlayer];
    [self loadHighscores];
	[self updateHighscores];
	if(currentScorePosition >= 0) {
		[self saveHighscores];
	}
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	
    //remove High scores tiltle
	//CCSprite *title = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608,192,225,57)];
	//[batchNode addChild:title z:5];
	//title.position = ccp(160,420);

	float start_y = 360.0f;
	float step = 27.0f;
	int count = 0;
	for(NSMutableArray *highscore in highscores) {
		NSString *player = [highscore objectAtIndex:0];
		int score = [[highscore objectAtIndex:1] intValue];
		
		CCLabelTTF *label1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",(count+1)] dimensions:CGSizeMake(30,40) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:14];
		[self addChild:label1 z:5];
		[label1 setColor:ccBLACK];
		[label1 setOpacity:200];
		label1.position = ccp(15,start_y-count*step-2.0f);
		
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:player dimensions:CGSizeMake(240,40) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:16];
		[self addChild:label2 z:5];
		[label2 setColor:ccBLACK];
		label2.position = ccp(160,start_y-count*step);

		CCLabelTTF *label3 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] dimensions:CGSizeMake(290,40) alignment:UITextAlignmentRight fontName:@"Arial" fontSize:16];
		[self addChild:label3 z:5];
		[label3 setColor:ccBLACK];
		[label3 setOpacity:200];
		label3.position = ccp(160,start_y-count*step);
		
		count++;
		if(count == 10) break;
	}

	CCMenuItem *button1 = [CCMenuItemImage itemFromNormalImage:@"playAgainButton4.png" selectedImage:@"playAgainButton4.png" target:self selector:@selector(button1Callback:)];
	CCMenuItem *button2 = [CCMenuItemImage itemFromNormalImage:@"changePlayerButton.png" selectedImage:@"changePlayerButton.png" target:self selector:@selector(button2Callback:)];
	
	CCMenu *menu = [CCMenu menuWithItems: button1, button2, nil];

	//[menu alignItemsVerticallyWithPadding:9];
    [menu alignItemsHorizontallyWithPadding:9];
	menu.position = ccp(160,78);
	
	[self addChild:menu];
    
    //显示广告
    [self showAD:true];
    
    //播放马声
    [[SimpleAudioEngine sharedEngine] playEffect:@"马-END.wav"];
	
	return self;
}

- (void)dealloc {
//	NSLog(@"Highscores::dealloc");
	[highscores release];
	[super dealloc];
}

- (void)loadCurrentPlayer {
//	NSLog(@"loadCurrentPlayer");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	currentPlayer = nil;
	currentPlayer = [defaults objectForKey:@"player"];
	if(!currentPlayer) {
		currentPlayer = @"小小马";
	}

//	NSLog(@"currentPlayer = %@",currentPlayer);
}

- (void)loadHighscores {
//	NSLog(@"loadHighscores");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	highscores = nil;
	highscores = [[NSMutableArray alloc] initWithArray: [defaults objectForKey:@"highscores"]];
#ifdef RESET_DEFAULTS	
	[highscores removeAllObjects];
#endif
	if([highscores count] == 0) {
		[highscores addObject:[NSArray arrayWithObjects:@"神马老板",[NSNumber numberWithInt:1000000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"神马老大",[NSNumber numberWithInt:750000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"神马",[NSNumber numberWithInt:500000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"雷天马",[NSNumber numberWithInt:250000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"风天马",[NSNumber numberWithInt:100000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"火天马",[NSNumber numberWithInt:50000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"北天马",[NSNumber numberWithInt:20000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"南天马",[NSNumber numberWithInt:10000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"大天马",[NSNumber numberWithInt:5000],nil]];
		[highscores addObject:[NSArray arrayWithObjects:@"小天马",[NSNumber numberWithInt:1000],nil]];
	}
#ifdef RESET_DEFAULTS	
	[self saveHighscores];
#endif
}

- (void)updateHighscores {
//	NSLog(@"updateHighscores");
	
	currentScorePosition = -1;
	int count = 0;
	for(NSMutableArray *highscore in highscores) {
		int score = [[highscore objectAtIndex:1] intValue];
		
		if(currentScore >= score) {
			currentScorePosition = count;
			break;
		}
		count++;
	}
	
	if(currentScorePosition >= 0) {
		[highscores insertObject:[NSArray arrayWithObjects:currentPlayer,[NSNumber numberWithInt:currentScore],nil] atIndex:currentScorePosition];
		[highscores removeLastObject];
	}
}

- (void)saveCurrentPlayer {
//	NSLog(@"saveCurrentPlayer");
//	NSLog(@"currentPlayer = %@",currentPlayer);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:currentPlayer forKey:@"player"];
}

- (void)saveHighscores {
//	NSLog(@"saveHighscores");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:highscores forKey:@"highscores"];
}

- (void)button1Callback:(id)sender {
//	NSLog(@"button1Callback");

	CCTransitionScene *ts = [CCTransitionFade transitionWithDuration:0.5f scene:[Game scene:currentScore] withColor:ccWHITE];
	[[CCDirector sharedDirector] replaceScene:ts];
    
    //重新加载AD
    [self reloadAD];
}

- (void)button2Callback:(id)sender {
//	NSLog(@"button2Callback");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改名称" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] ;
    alertView.tag = 2;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    alertView.delegate = self;
    [alertView show];
}


- (void)draw {
	[super draw];
	
	if(currentScorePosition < 0) return;

	glColor4f(0.0f, 0.0f, 0.0f, 0.2f);

	float w = 320.0f;
	float h = 27.0f;
	float x = (320.0f - w) / 2.0f;
	float y = 359.0f - currentScorePosition * h;

	GLfloat vertices[4][2];	
	GLubyte indices[4] = { 0, 1, 3, 2 };

	vertices[0][0] = x;		vertices[0][1] = y;
	vertices[1][0] = x+w;	vertices[1][1] = y;
	vertices[2][0] = x+w;	vertices[2][1] = y+h;
	vertices[3][0] = x;		vertices[3][1] = y+h;
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, indices);

	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
}

- (void)changePlayerDone:(NSString*)pname {
    currentPlayer = pname;//[changePlayerTextField.text retain];
	[self saveCurrentPlayer];
	if(currentScorePosition >= 0) {
		[highscores removeObjectAtIndex:currentScorePosition];
		[highscores addObject:[NSArray arrayWithObjects:@"HorseJump",[NSNumber numberWithInt:0],nil]];
		[self saveHighscores];
		[[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:1 scene:[Highscores sceneWithScore:currentScore] withColor:ccWHITE]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	NSLog(@"alertView:clickedButtonAtIndex: %i",buttonIndex);
	
    UITextField * alertTextField = [alertView textFieldAtIndex:0];
    NSLog(@"alerttextfiled - %@",alertTextField.text);
    
	if(buttonIndex == 1) {
        [self changePlayerDone:alertTextField.text];
	} else {
		// nothing
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	NSLog(@"textFieldShouldReturn");
	[changePlayerAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self changePlayerDone:textField.text];
	return YES;
}

@end
