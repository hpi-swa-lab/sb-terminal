Class {
	#name : #SBBashCommandInformation,
	#superclass : #Object,
	#instVars : [
		'terminal',
		'fullCommand',
		'mainCommand',
		'searchString',
		'previousBlock',
		'commandObject',
		'sandblockEditor',
		'onlyShowFlags',
		'onlyShowFileNames',
		'currentBlock'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> commandObject [

	^ commandObject
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> commandObject: anObject [

	commandObject := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> currentBlock [

	^ currentBlock
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> currentBlock: aBlock [

	currentBlock := aBlock
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> fullCommand [

	^ fullCommand
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> fullCommand: aString [

	fullCommand := aString
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> mainCommand [

	mainCommand ifNotNil: [^ mainCommand].
	searchString ifNil: [^ self trimFlagsAndDoFrom: fullCommand] ifNotNil: [
		searchString = fullCommand
			ifTrue: [^ '']
			ifFalse: [^ self trimFlagsAndDoFrom: (fullCommand from: 1 to: fullCommand size - searchString size - 1)]]
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> mainCommand: aString [

	mainCommand := aString
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> onlyShowFileNames [

	^ onlyShowFileNames
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> onlyShowFileNames: aBoolean [

	onlyShowFileNames := aBoolean
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> onlyShowFlags [

	^ onlyShowFlags
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> onlyShowFlags: aBoolean [

	onlyShowFlags := aBoolean
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> previousBlock [

	^ previousBlock
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> previousBlock: anObject [

	previousBlock := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> sandblockEditor [

	^ sandblockEditor
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> sandblockEditor: anObject [

	sandblockEditor := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> searchString [

	^ searchString
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> searchString: aString [

	searchString := aString
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> terminal [

	^ terminal
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> terminal: anObject [

	terminal := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> trimFlagsAndDoFrom: aString [

	| withoutDo upTo |
	withoutDo := (aString beginsWith: 'do ')
		ifTrue: [aString from: 4]
		ifFalse: [aString].
	upTo := withoutDo findString: '-'.
	upTo > 1 ifTrue: [^ withoutDo from: 1 to: upTo - 2] ifFalse: [^ withoutDo withBlanksTrimmed]
]
