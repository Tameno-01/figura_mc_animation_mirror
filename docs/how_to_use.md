# How to use

I know it's long, but please read try to read this whole guide, it should cover everything.

**Installation** is covered in step 1.

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

- [Vanilla](head/vanilla_rig_requirements.md) (Head can detach for more expressiveness)
- [Rigged](head/rigged_rig_requirements.md) (Head stays in place, can optionally have a neck)

**Torso:**

- [Vanilla](torso/vanilla_rig_requirements.md) (Single joint)
- [Rigged](torso/rigged_rig_requirements.md) (2 or more joints)

**Arms:**

- [Vanilla](arm/vanilla_rig_requirements.md) (Single joint)
- [Rigged](arm/rigged_rig_requirements.md) (With and elbow joint and an optional hand)

**Legs:**

- [Vanilla](leg/vanilla_rig_requirements.md) (Single joint)
- [Rigged](leg/rigged_rig_requirements.md) (With and knee joint and an optional foot)
- [Digitigrade](leg/digitigarde_rig_requirements.md) (Animal legs)

## Step 0.3: Set rotations back to what they were

You may now undo what you did in step 0.1 (if you had any rotated joints in the first place).

# Step 1: Install the API

Go to the [main page](https://github.com/Tameno-01/figura_mc_animation_mirror) of this repo and click on the `<> Code` button, then `Download ZIP`.

![A screenshot of the main page of this github repo with arrows pointing at the "Code" and "Download ZIP" buttons](download_zip.png)

Extract the zip and locate the folder called `animation_mirror`. it may be inside one or several sub-folders. Place the `animation_mirror` folder in your avatar's root folder, the same folder containing the `avatar.json` file.

# Step 2: Make the body

In Animation Mirror, "making" a body refers to gathering all the information performing the setup necessary to read and set its pose.

It is recommended you put all the following code snippets in either your main lua file or a lua file created specifically for animation mirror.

## Step 2.1: Make the body parts

You "make" a body by "making" 6 body parts, the head, the torso, the left arm, the right arm, the left leg and the right leg.

Depending on what type of rig each of those parts has, the setup is slightly different, so i've written separate guides for all supported types of rig. 

**Head:**

- [Vanilla](head/vanilla_setup.md)
- [Rigged](head/rigged_setup.md)

**Torso:**

- [Vanilla](torso/vanilla_setup.md)
- [Rigged](torso/rigged_setup.md)

**Arms:**

- [Vanilla](arm/vanilla_setup.md)
- [Rigged](arm/rigged_setup.md)

**Legs:**

- [Vanilla](leg/vanilla_setup.md)
- [Rigged](leg/rigged_setup.md)
- [Digitigrade](leg/digitigarde_setup.md)

## Step 2.2: Make and assign the full body

First, require the body maker.

```lua
local BodyMaker = require("animation_mirror/body_maker/core")
```

You can then use it to make the body using all the body parts you made and assign it to animation mirror.

```lua
local animation_mirror_body = BodyMaker.make(
	animation_mirror_head,
	animation_mirror_torso,
	animation_mirror_left_arm,
	animation_mirror_right_arm,
	animation_mirror_left_leg,
	animation_mirror_right_leg,
	nil, -- root (ModelPart, defaults to the models global)
	nil -- auto reset (bool, defaults to true)
)

AnimationMirror.set_body(animation_mirror_body)
```

Note the last 2 `nil` parameters, they're optional, but very important.

`root` is what Animation Mirror considers the root of your model, any movements of this part or any of its parents will be ignored. Use this wisely. Animation Mirror does not account for scale in any way, so if you scale the root of your model, either to change your size or for a squash and stretch effect, set whatever part you're scaling as the `root`. Similarly, if your avatar uses `renderer.setRootRotationAllowed(false)` and does yaw manually, set `root` to whatever part is being yawed by your code.

`auto reset` determines whether the position, rotation and scale of parts gets reset after you finish mirroring someone. If true, parts will be reset to whatever state they were in when all the `make` functions were called. It's recommended to leave this as `true`.

# Step 3: Hook Animation Mirror into your emotes system