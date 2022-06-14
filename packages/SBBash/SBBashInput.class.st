Class {
	#name : #SBBashInput,
	#superclass : #SBBash,
	#instVars : [
		'terminal',
		'current',
		'processReturn'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInput class >> confirm: aBlock [
	<action>

	| pty terminal command |
	command := (aBlock orOwnerSuchThat: [:b | b type = #command]) sourceString.
	terminal := aBlock containingArtefact.
	pty := terminal pty.
	terminal state: #hidden.
	terminal waitingForCommandString: command.
	pty nextPutAll: command.
	pty nextPut: Character return
]

{ #category : #'as yet unclassified' }
SBBashInput >> terminal [

	^ self containingArtefact
]
