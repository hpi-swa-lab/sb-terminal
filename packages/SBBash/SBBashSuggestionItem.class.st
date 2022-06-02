Class {
	#name : #SBBashSuggestionItem,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'flag'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashSuggestionItem class >> selector: aSymbol label: aLabelString flag: aFlagString [

	^ self new
		selector: aSymbol label: aLabelString flag: aFlagString;
		yourself
]

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> flag [

	^ flag
]

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> flag: aString [

	flag := aString
]

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> selector: aSelectorString label: aLabelString flag: aFlagString [

	super selector: aSelectorString label: aLabelString.
	flag := aFlagString
]
