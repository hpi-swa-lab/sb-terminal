Class {
	#name : #SBBashTSBlockSuggestion,
	#superclass : #SBTSBlockSuggestion,
	#instVars : [
		'option',
		'command'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> blocks: aCollection in: anEditor popup: aPopup [

	disambiguatePopup := aPopup.
	self
		preview: (anEditor newSelectionContainer
			addAllMorphs: aCollection;
			width: 400;
			imageForm)
		previewOnly: false.
	^ blocks := aCollection
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> command [

	^ command
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> command: anObject [

	command := anObject
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> option [

	^ option
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> option: aString [

	option := aString
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> selector: aString [

	| container |
	container := self firstSubmorph.
	selector := aString.
	container addMorphBack: (SBMultilineOwnTextMorph new
		contents: aString;
		hResizing: #spaceFill;
		maxWidth: 400)
]
