Class {
	#name : #SBBashInsertSuggestionItem,
	#superclass : #SBInsertSuggestionItem,
	#instVars : [
		'option',
		'command',
		'blocks',
		'morphs'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> command [

	^ command
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> command: anObject [

	command := anObject
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> morphs: aCollection editor: anEditor [

	| wrapper |
	morphs := aCollection.
	wrapper := SBBlock new
		addAllMorphsBack: aCollection;
		changeTableLayout;
		listDirection: #leftToRight.
	self addMorphBack: (wrapper wrapOffscreen: anEditor) imageForm asMorph
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> option [

	^ option
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> option: anObject [

	option := anObject
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> selector: aString [

	| container |
	container := self firstSubmorph.
	selector := aString.
	container addMorphBack: (SBMultilineOwnTextMorph new
		contents: aString;
		hResizing: #spaceFill;
		maxWidth: 400)
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> useSuggestionOn: aCommand in: anEditor [

	anEditor do: (aCommand morphs: morphs)
]
