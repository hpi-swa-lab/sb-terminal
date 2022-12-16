Class {
	#name : #SBBashInsertSuggestionItem,
	#superclass : #SBInsertSuggestionItem,
	#instVars : [
		'option',
		'terminalCommand',
		'blocks',
		'morphs',
		'key',
		'selectorMorph',
		'command',
		'showMoreButton'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> active: aBoolean [

	super active: aBoolean.
	selectorMorph ifNotNil: [
		selectorMorph contents: (aBoolean
			ifTrue: [selector sbSuggestionLimitedTo: self activeLimit maxLines: self activeLines]
			ifFalse: [selector sbSuggestionLimitedTo: self inactiveLimit maxLines: self inactiveLines])].
	self firstSubmorph height: 0
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> activeLies [

	^ 10
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> activeLimit [

	^ 400
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> activeLines [

	^ 10
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> inactiveLimit [
	^ 100
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> inactiveLines [
	^ 3
]

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
SBBashInsertSuggestionItem >> printString: aString limitedTo: aNumber [ 
	| limitedString |
	limitedString := String
				streamContents: [:s | aString printOn: s]
				limitedTo: aNumber.
	limitedString size < aNumber
		ifTrue: [^ limitedString].
	^ limitedString , '...'
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> selector: aString [

	| container |
	container := self firstSubmorph.
	selector := aString.
	
	container addMorphBack: (selectorMorph := SBMultilineOwnTextMorph new
		contents: (aString sbSuggestionLimitedTo: self inactiveLimit maxLines: self inactiveLines);
		hResizing: #spaceFill;
		maxWidth: 400).
	
	aString size > self activeLimit ifTrue: [ | commandString |
		commandString := (morphs collect: [:r |
			r sourceString ifNotEmpty: [r sourceString] ifEmpty: [r submorphs first placeholderText]]) joinSeparatedBy: ' '.
		showMoreButton := SBButton new
			label: 'Show full'
			shortcut: nil
			do: [UIManager default inform: commandString, String cr, selector].
		container addMorphBack: showMoreButton]
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

	| command |
	command := aCommand element type = #'flag_argument'
		ifTrue: [self wordInsertPositionAfterFlagInsert: aCommand]
		ifFalse: [aCommand].
	
	anEditor do: (command morphs: (morphs gather: [:morph | SBTSInputParser new adaptSlotsFor: {morph} to: command element])).
	anEditor selection ifNotNil: [
		anEditor selection contents ifNotEmpty: [
			anEditor selection startInputAtEnd.
			anEditor performForSelection: #moveCursorRight]]
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> wordInsertPositionAfterFlagInsert: aCommand [

	| takeNext |
	takeNext := false.
	aCommand container parentSandblock cursorPositionsDo: [:cursor |
		(takeNext and: [cursor isInsert]) ifTrue: [^ cursor command].
		(cursor isInsert and: [cursor command container = aCommand container]) ifTrue: [takeNext := true]].
	self assert: false
]
