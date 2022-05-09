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
SBBashCommandBlock >> initialize [

	super initialize.
	self
		addMorphBack: (SBRow new
			changeTableLayout;
			addMorphBack: (ps1 := SBTextBubble multiLine vResizing: #shrinkWrap);
			addMorphBack: (input := SBBashInputTextBubble multiLine
				placeholderText: 'type here';
				hResizing: #spaceFill;
				vResizing: #spaceFill);
			hResizing: #spaceFill;
			cellGap: 2);
		addMorphBack: (output := SBTextBubble multiLine
			hResizing: #spaceFill;
			vResizing: #shrinkWrap);
		cellGap: 2;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		changeTableLayout
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> output [

	^ output contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> output: aString [

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
