# Table of Contents

- [Aura Components](#Aura-Components)
  - [NewCaseAuraWrapper](#NewCaseAuraWrapper)
    <br>

# **Aura Components**

## NewCaseAuraWrapper

This was created to override the standard "New" button behaviour on **`Case`** object.

It was designed to support below;

- Mainly focused on delivering Complaints module (CMOS) requirement around re-deirecting users to a custom LWC component for Complaints specific Case record-types.

- Currently supports Creating new stand-alone Cases as well as child Cases related to Account records (via related list).

- Custom logic is in place to support above functionality on both lightning standard and ligtning console navigation experiences.

**`IMPORTANT :`** When there is a requirement to associate Cases with more parent objects in the future, the logic on JS controller needs to be modified accordingly to pre-populate the parent record link.
