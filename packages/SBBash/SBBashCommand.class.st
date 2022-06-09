Class {
	#name : #SBBashCommand,
	#superclass : #Object,
	#instVars : [
		'fullCommandString',
		'subcommands',
		'options',
		'description',
		'synopsis'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommand >> commandString [

	^ fullCommandString from: 1 to: fullCommandString lastSpacePosition
]

{ #category : #'as yet unclassified' }
SBBashCommand >> description [

	^ description
]

{ #category : #'as yet unclassified' }
SBBashCommand >> description: anObject [

	description := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommand >> fullCommandString [

	^ fullCommandString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> fullCommandString: aString [

	fullCommandString := aString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> options [

	^ options
]

{ #category : #'as yet unclassified' }
SBBashCommand >> options: anObject [

	options := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommand >> subcommands [

	^ subcommands
]

{ #category : #'as yet unclassified' }
SBBashCommand >> subcommands: anObject [

	subcommands := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommand >> synopsis [

	^ synopsis
]

{ #category : #'as yet unclassified' }
SBBashCommand >> synopsis: aString [

	synopsis := aString
]
