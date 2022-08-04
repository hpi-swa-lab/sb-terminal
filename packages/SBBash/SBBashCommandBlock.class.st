Class {
	#name : #SBBashCommandBlock,
	#superclass : #SBBlock,
	#instVars : [
		'ps1',
		'output',
		'input'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> addInput: aString [

	input contents: input contents, aString.
	self moveCursorToEnd
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> floating [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> focus [

	input startInputAtEnd
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> initialize [

	super initialize.
	self
		addMorphBack: (SBRow new
			changeTableLayout;
			addMorphBack: (ps1 := SBBashFormattedTextBubble multiLine
				vResizing: #shrinkWrap;
				focusable: false);
			addMorphBack: (input := (SBBashInput parseToplevel: '')
				hResizing: #spaceFill;
				vResizing: #spaceFill;
				layoutInset: 0;
				minHeight: TextStyle defaultFont height);
			hResizing: #spaceFill;
			cellGap: 2);
		addMorphBack: (output := SBBashFormattedTextBubble multiLine
			hResizing: #spaceFill;
			vResizing: #shrinkWrap;
			maxWidth: 80 * 8;
			visible: false;
			focusable: false);
		cellGap: 2;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		changeTableLayout
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> input [

	^ input contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> input: aString [

	input contents: aString.
	self moveCursorToEnd
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> inputBlock [

	^ input
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> output [

	^ output contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> output: aString [

	output visible ifFalse: [output visible: true].
	output contents: output contents asText, aString
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> ps1 [

	^ ps1 contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> ps1: aString [

	| current group |
	ps1 contents: ps1 contents asText, aString.
	current := ps1 contents asString.
	group := (current from: (current findString: ':') + 1 to: current size) findTokens: '/'.
	ps1 contents: ((group collect: [:pathPart | pathPart = group last ifTrue: [pathPart] ifFalse: [pathPart first]]) joinSeparatedBy: '/')
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> wasSelected [

	self focus
]
