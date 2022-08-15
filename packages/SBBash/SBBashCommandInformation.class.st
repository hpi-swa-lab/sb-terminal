Class {
	#name : #SBBashCommandInformation,
	#superclass : #Object,
	#instVars : [
		'terminal',
		'fullCommand',
		'searchString',
		'previousBlock',
		'commandObject',
		'sandblockEditor',
		'onlyShowFlags',
		'onlyShowFileNames'
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
SBBashCommandInformation >> fullCommand [

	^ fullCommand
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> fullCommand: aString [

	fullCommand := aString
]

{ #category : #'as yet unclassified' }
SBBashCommandInformation >> mainCommand [

	searchString ifNil: [^ self trimFlagsFrom: fullCommand] ifNotNil: [
		searchString = fullCommand
			ifTrue: [^ '']
			ifFalse: [^ self trimFlagsFrom: (fullCommand from: 1 to: fullCommand size - searchString size - 1)]]
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
SBBashCommandInformation >> trimFlagsFrom: aString [

	| upTo |
	upTo := aString findString: '-'.
	upTo > 0 ifTrue: [^ aString from: 1 to: upTo - 2] ifFalse: [^ aString withBlanksTrimmed]
]
