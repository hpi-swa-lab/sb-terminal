Class {
	#name : #SBBashCommandBlock,
	#superclass : #SBBlock,
	#instVars : [
		'ps1',
		'output'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> initialize [

	super initialize.
	self
		addMorphBack: (SBRow new
			addMorphBack: (ps1 := SBTextBubble new
				contents: 'ps1';
				hResizing: #shrinkWrap);
			addMorphBack: (SBTextBubble new hResizing: #spaceFill));
		addMorphBack: (output := SBTextBubble new
			hResizing: #spaceFill;
			vResizing: #shrinkWrap)
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
