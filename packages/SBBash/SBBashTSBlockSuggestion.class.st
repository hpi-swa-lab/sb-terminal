Class {
	#name : #SBBashTSBlockSuggestion,
	#superclass : #SBTSBlockSuggestion,
	#instVars : [
		'option',
		'terminalCommand',
		'key'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> blocks: aCollection in: anEditor [

	| generatedCommand |
	generatedCommand := SBReplaceMultipleCommand new
		target: anEditor selection
		replacers: (aCollection collect: [:m | m isTSBlock ifTrue: [m adaptSlotFor: anEditor selection slot] ifFalse: [m]]).
	self command: generatedCommand in: anEditor
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> blocks: aCollection in: anEditor popup: aPopup [

	"deprecated?"
	disambiguatePopup := aPopup.
	command := SBReplaceMultipleCommand new
		target: anEditor selection
		replacers: (aCollection collect: [:m | m isTSBlock ifTrue: [m adaptSlotFor: anEditor selection slot] ifFalse: [m]]).
	self
		preview: (anEditor newSelectionContainer
			addAllMorphs: command morphs;
			width: 800;
			changeTableLayout;
			listDirection: #leftToRight;
			imageForm)
		previewOnly: false
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> blocks: aCollection in: anEditor popup_: aPopup [

	super
		blocks: (SBReplaceMultipleCommand new
			target: anEditor selection
			replacers: (aCollection collect: [:m | m isTSBlock ifTrue: [m adaptSlotFor: anEditor selection slot] ifFalse: [m]]))
		in: anEditor
		popup: aPopup
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> command: aCommand in: anEditor popup: aPopup [

	disambiguatePopup := aPopup.
	self
		preview: (anEditor newSelectionContainer
			addAllMorphs: aCommand morphs;
			changeTableLayout;
			listDirection: #leftToRight;
			width: 400;
			imageForm)
		previewOnly: false.
	command := aCommand
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> key [

	key ifNotNil: [^ key] ifNil: [^ option]
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> key: aString [

	key := aString
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
SBBashTSBlockSuggestion >> terminalCommand [

	^ terminalCommand
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> terminalCommand: anObject [

	terminalCommand := anObject
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> useSuggestionOn: aBlock in: anEditor [

	disambiguatePopup ifNotNil: [:popup | popup applyCommand: command] ifNil: [
		anEditor do: command.
		anEditor selection ifNotNil: [
			"look for a morph that is all empty --> probably best place to start input. otherwise, we move after all the blocks, to the next input position"
			command morphs
				detect: [:morph | morph contents isEmpty]
				ifFound: [:morph | morph startInputAtStart]
				ifNone: [
					anEditor selection startInputAtEnd.
					anEditor performForSelection: #moveCursorRight]]]
]
