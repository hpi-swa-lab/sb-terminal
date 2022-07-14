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

	super
		blocks: (SBReplaceMultipleCommand new
			target: anEditor selection
			replacers: (aCollection collect: [:m | m isTSBlock ifTrue: [m adaptSlotFor: anEditor selection slot] ifFalse: [m]]))
		in: anEditor
		popup: aPopup
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

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> useSuggestionOn: aBlock in: anEditor [

	disambiguatePopup
		ifNotNil: [:popup | popup applyChoice: blocks]
		ifNil: [anEditor do: (SBReplaceMultipleCommand new target: aBlock replacers: blocks)]
]
