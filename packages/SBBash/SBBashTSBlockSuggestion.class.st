Class {
	#name : #SBBashTSBlockSuggestion,
	#superclass : #SBTSBlockSuggestion,
	#instVars : [
		'option',
		'terminalCommand',
		'key',
		'icon',
		'alternatives',
		'selectorMorph'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> active: aBoolean [

	super active: aBoolean.
	selectorMorph contents: (aBoolean ifTrue: [selector] ifFalse: [selector printStringLimitedTo: 50]).
	self height: 0.
	selectorMorph height: 0.
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> alternatives [

	^ alternatives
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> alternatives: anObject [


	alternatives := anObject
]

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
SBBashTSBlockSuggestion >> icon: anObject [

	| container |
	container := self firstSubmorph.
	icon := anObject.
	container addMorphFront: icon
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
SBBashTSBlockSuggestion >> preview: aForm previewOnly: aBoolean [

	| container |
	self addMorphBack: ((container := SBRow new) addMorphBack: (preview := aForm asMorph)).
	alternatives ifNotNil: [container addMorphBack: (SBMultilineOwnTextMorph new contents: ' (', (alternatives, ')'))].
	aBoolean ifTrue: [self firstSubmorph delete]
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> selector: aString [

	| container |
	container := self firstSubmorph.
	selector := aString.
	container addMorphBack: (selectorMorph := SBMultilineOwnTextMorph new
		contents: (aString printStringLimitedTo: 50);
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
					"for suggestions for directories (key ends with '/'), we want to keep the selection in the last block; for other suggestions, we want to end up at the insert position behind the last block"
					(key isNil or: [(key endsWith: '/') not]) ifTrue: [
						"??? not sure"
						anEditor performForSelection: #moveCursorRight
						"anEditor performForSelection: #moveCursorRight"]]]]
]
