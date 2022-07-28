Class {
	#name : #SBBashInsertSuggestionItem,
	#superclass : #SBInsertSuggestionItem,
	#instVars : [
		'option',
		'terminalCommand',
		'blocks',
		'morphs',
		'key'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> key [

	key ifNotNil: [^ key] ifNil: [^ option]
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> key: aString [

	key := aString
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
SBBashInsertSuggestionItem >> terminalCommand [

	^ terminalCommand
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> terminalCommand: anObject [

	terminalCommand := anObject
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> useSuggestionOn: aCommand in: anEditor [

	anEditor do: (aCommand morphs: (SBTSInputParser new adaptSlotsFor: morphs to: aCommand element))
]
