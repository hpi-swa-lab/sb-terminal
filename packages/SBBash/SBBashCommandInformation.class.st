Class {
	#name : #SBBashCommandInformation,
	#superclass : #Object,
	#instVars : [
		'terminal',
		'fullCommand',
		'searchString',
		'commandObject',
		'sandblockEditor'
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
	"maybe check if searchString is actually at the end of fullCommand?"

	^ fullCommand from: 1 to: (fullCommand size - searchString size)
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
