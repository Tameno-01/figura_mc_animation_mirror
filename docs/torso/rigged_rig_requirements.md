# Rigged torso requirements.

The torso must have 2 or more joints, if it doesn't, see the [vanilla torso rig requirements](vanilla_rig_requirements.md).

The torso must be rigged bottom to top, in other words, the bottom-most joint should be the parent of the rest of the torso.

It is recommended that all the torso/spine joins are on the same X and Z position, in other words, they should all be in a straight vertical line. This is not necessary but will make mirroring other people look better.

There needs to be a joint at the top of the torso to tell Animation Mirror where the last torso segment ends, the neck or head joints suffice for this purpose.