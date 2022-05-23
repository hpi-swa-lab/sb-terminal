Class {
	#name : #SBBashCommand,
	#superclass : #Object,
	#instVars : [
		'commandString',
		'subcommands',
		'options',
		'description'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommand >> commandString [

	^ commandString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> commandString: anObject [

	commandString := anObject
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
