Class {
	#name : #SBBashTSBlockSuggestion,
	#superclass : #SBTSBlockSuggestion,
	#instVars : [
		'option',
		'terminalCommand',
		'key',
		'icon',
		'alternatives',
		'selectorMorph',
		'showMoreButton'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> active: aBoolean [

	super active: aBoolean.
	selectorMorph ifNotNil: [
		selectorMorph contents: (aBoolean
			ifTrue: [
				selector sbSuggestionLimitedTo: self activeLimit maxLines: self activeLines]
			ifFalse: [selector sbSuggestionLimitedTo: self inactiveLimit maxLines: self inactiveLines])].
	self firstSubmorph height: 0
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> activeLimit [

	^ 400
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> activeLines [

	^ 10
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
SBBashTSBlockSuggestion >> inactiveLimit [

	^ 100
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> inactiveLines [

	^ 3
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
SBBashTSBlockSuggestion >> printString: aString limitedTo: aNumber [

	| limitedString |
	limitedString := String streamContents: [:s | aString printOn: s] limitedTo: aNumber.
	limitedString size < aNumber ifTrue: [^ limitedString].
	^ limitedString, '...'
]

{ #category : #'as yet unclassified' }
SBBashTSBlockSuggestion >> selector: aString [

	| container |
	container := self firstSubmorph.
	selector := aString.
	
	container addMorphBack: (selectorMorph := SBMultilineOwnTextMorph new
		contents: (aString sbSuggestionLimitedTo: self inactiveLimit maxLines: self inactiveLines);
		hResizing: #spaceFill;
		maxWidth: 400).
	
	aString size > self activeLimit ifTrue: [ | commandString |
		commandString := (command morphs collect: [:r | r sourceString ifNotEmpty: [r sourceString] ifEmpty: [r submorphs first placeholderText]]) joinSeparatedBy: ' '.
		showMoreButton := SBButton new label: 'Show full' shortcut: nil do: [ | d |
			d := UserDialogBoxMorph new
				title: commandString;
				message: selector;
				createButton: 'Close' value: nil;
				exclusive: false;
				fullBounds;
				morphicLayerNumber: self class dialogLayer;
				moveToPreferredPosition;
				openInWorld.
			self currentHand newKeyboardFocus: d defaultFocusMorph].
		container addMorphBack: showMoreButton]
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
