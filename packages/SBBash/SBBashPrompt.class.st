Class {
	#name : #SBBashPrompt,
	#superclass : #SBBlock,
	#instVars : [
		'commandBlocks',
		'tty',
		'pty'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashPrompt >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBTextBubble new
			placeholderText: 'Command inspect ...';
			when: #contentsChanged send: #update to: self;
			layoutInset: 4);
		addMorphBack: (SBButton new onClick: [self startREPL]);
		addMorphBack: (tty := SBBashTextBubble multiLine layoutInset: 4);
		cellGap: 4;
		hResizing: #rigid;
		vResizing: #shrinkWrap;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		width: 300;
		changeTableLayout;
		layoutInset: 4
]

{ #category : #'as yet unclassified' }
SBBashPrompt >> startREPL [

	| input |
	pty := tty pty.
	[
		[
			input := UIManager default request: 'input'.
			pty nextPutAll: input.
			pty nextPut: Character return] doWhileFalse: [input isEmpty]] fork
]

{ #category : #'as yet unclassified' }
SBBashPrompt >> update [

	[ | newBlock |
		newBlock := (SBTSFileParser new parse: self firstSubmorph contents language: SBBash)
			localColorPolicy: (self colorPolicy copy enlarge: true);
			hResizing: #spaceFill.
		commandBlocks ifNotNil: [commandBlocks delete].
		self addMorph: (commandBlocks := newBlock) asElementNumber: 2]
		on: SBTSSyntaxError
		do: [:err | ]
]
