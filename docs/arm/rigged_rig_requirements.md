# Rigged arm requirements

The arm must have an elbow joint for this page to apply, if it doesn't, see the [vanilla arm rig requirements](vanilla_rig_requirements.md).

Unless you're using a [vanilla-styled torso](../torso/vanilla_rig_requirements.md), the arm must be directly or indirectly parented to the torso.

The arm must be in an I, A, T or Y pose (tho why would you ever model in a Y pose...).

The elbow can be bent, but if it is, it must only bend around the z axis.

The hand is optional, but if it's not present, there must be an empty group placed where the hand would be. This is to tell Animation Mirror where the lower arm ends.

If the hand is present, the wrist must not be bent and the thumb must be facing forward (towards negative Z in blockbench).