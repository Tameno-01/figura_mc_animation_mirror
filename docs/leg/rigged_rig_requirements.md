# Rigged leg requirements

The leg must have an knee joint for this page to apply, if it doesn't, see the [vanilla leg rig requirements](vanilla_rig_requirements.md).

Unless you're using a [vanilla-styled torso](../torso/vanilla_rig_requirements.md), the leg must be directly or indirectly parented to the torso.

The joints must not be bend, the leg must be in an I pose.

The foot is optional, but if it's not present, there must be an empty group placed where the foot would be. This is to tell Animation Mirror where the lower leg ends.

If the foot is present, it must be oriented with the toes facing forward (towards negative Z in blockbench).