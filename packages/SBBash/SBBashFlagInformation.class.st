Class {
	#name : #SBBashFlagInformation,
	#superclass : #Object,
	#instVars : [
		'description',
		'flags',
		'arguments',
		'optionals',
		'morphs',
		'searchCriterium'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> arguments [

	^ arguments
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> arguments: anObject [

	arguments := anObject
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> description [

	^ description
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> description: anObject [

	description := anObject
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> firstFlag [

	flags ifNotEmpty: [^ flags first] ifEmpty: [^ '']
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> flags [

	^ flags
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> flags: anObject [

	flags := anObject
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> flagsJoined [

	^ flags joinSeparatedBy: ', '
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> morphs [

	^ morphs
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> morphs: anObject [

	morphs := anObject
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> optionals [

	^ optionals
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> optionals: anObject [

	optionals := anObject
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> searchCriterium [

	^ searchCriterium
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> searchCriterium: aString [

	searchCriterium := aString
]

{ #category : #'as yet unclassified' }
SBBashFlagInformation >> suggestionText [

	^ self flagsJoined, ': ', description
]
