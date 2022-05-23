Class {
	#name : #SBBashCommandOption,
	#superclass : #Object,
	#instVars : [
		'flags',
		'description'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommandOption >> description [

	^ description
]

{ #category : #'as yet unclassified' }
SBBashCommandOption >> description: anObject [

	description := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommandOption >> flags [

	^ flags
]

{ #category : #'as yet unclassified' }
SBBashCommandOption >> flags: anObject [

	flags := anObject
]
