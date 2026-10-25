# WARNING! These docs are incomplete!!

I'm uploading this to github mostly to test if things are working

# Step 0: Rig Requirements

Sadly, not all rigs are compatible with Animation Mirror. For starters, they all have to be humanoid, the more your rig deviates from a human, the more likely animation mirror does not support it.

**Things animation mirror does support:**

- Vanilla-styled rigs (no elbows, no hands, no knees, no feet and no articulation for the torso)
- Fully articulated rigs (with elbows, hands, knees, feet and a torso with any number of spine joints)
- Arms with elbows but no hands
- Legs with knees but no feet
- Digitigrade legs (with or without feet/toes)

Additionally, it is worth noting that all of the above can be mixed and matched at will. For example, if your avatar has a single-joint torso, fully rigged arms, and legs with knees but no feet, that's perfectly fine.

## Step 0.1: Temporarily set all joints's rotation to 0

Animation Mirror does not care what rotations joints have in blockbench, however, the **rest pose** of your model does matter. To see this pose and verify it is supported, set their rotation to 0. This should be the state they're all already in.

![A Blockbench screenshot showing the rotation of a group set to 0, 0, 0](0_rot.png)

## Step 0.2: Valid rest poses

Animation mirror treats each body part as a separate, individually configurable thing, more precisely, it considers the following parts: Head, torso, left arm, right arm, left leg and right leg.

Depending on which style of rig each part has, what's considered a valid rest pose is different. The following are precise definitions of the valid rest poses each type of rig can have, categorized by body part. You only need to read the ones that apply to your rig.

**Head:**

- Vanilla styled (Head can detach for more expressiveness)
- Rigged (Head stays in place, can optionally have a neck)

**Torso:**

- Vanilla (Single joint)
- Rigged (2 or more joints)

**Arms:**

- Vanilla (Single joint)
- Rigged (With and elbow joint and an optional hand)

**Legs:**

- Vanilla (Single joint)
- Rigged (With and knee joint and an optional foot)
- Digitigrade (Animal legs)

## Step 0.3: Set rotations back to what they were

You may now undo what you did in step 0.1 (if you had any rotated joints in the first place)

## Step 1: Install the API

