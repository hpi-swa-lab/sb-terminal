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
			changeTableLayout;
			addMorphBack: (ps1 := SBTextBubble new vResizing: #shrinkWrap);
			addMorphBack: (SBTextBubble new
				contents: 'TODO: type here';
				hResizing: #spaceFill;
				vResizing: #spaceFill);
			hResizing: #spaceFill;
			cellGap: 2);
		addMorphBack: (output := SBTextBubble new
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

	output contents: output contents, aString asString
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> ps1 [

	^ ps1 contents
]

{ #category : #'as yet unclassified' }
SBBashCommandBlock >> ps1: aString [

	ps1 contents: ps1 contents, aString asString
]
