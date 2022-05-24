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
			addMorphBack: (input := SBBashInputTextBubble multiLine
				placeholderText: 'type here';
				hResizing: #spaceFill;
				vResizing: #spaceFill);
			hResizing: #spaceFill;
			cellGap: 2);
		addMorphBack: (output := SBBashFormattedTextBubble multiLine
			hResizing: #spaceFill;
			vResizing: #shrinkWrap;
			focusable: true;
			visible: false);
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

	input contents: input contents, aString
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> output [

	^ output contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> output: aString [

	output visible ifFalse: (output visible: true).
	output contents: output contents asText, aString
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> ps1 [

	^ ps1 contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> ps1: aString [

	ps1 contents: ps1 contents asText, aString
]
