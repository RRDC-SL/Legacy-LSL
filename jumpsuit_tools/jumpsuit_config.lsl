string  s_inmateNumTex      = "";
string  s_uSuitTexNormal    = "";
string  s_uSuitTexTrustee   = "";

setInmateNumber(string iNum) // Sets the number on the uniform.
{
    if (llStringLength(iNum) != 5 || ((integer)iNum) <= 0)
    {
        iNum = "00000"; // Throw out bad inmate numbers.
    }

    integer i;
    for (i = 0; i < 5; i++) // Ubase=0.088, VBase=-0.085.
    {
        integer digit = (integer)llGetSubString(iNum, i, i);
        llSetLinkPrimitiveParamsFast(2, [
            PRIM_TEXTURE, (i+1), s_inmateNumTex, <1.0, 1.0, 0.0>,
            <((digit % 5) * 0.088), ((digit > 4) * -0.085), 0.0>, 0.0
        ]);
    }
}

setInmateRank(integer rank) // Sets the inmate rank. Normal=0, 1=Trustee.
{
    if (rank) // Trustee.
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_TEXTURE, 2, s_uSuitTexTrustee, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_TEXTURE, 4, s_uSuitTexTrustee, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
        ]);
    }
    else // Normal.
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_TEXTURE, 2, s_uSuitTexNormal, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
            PRIM_TEXTURE, 4, s_uSuitTexNormal, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
        ]);
    }
}

setInmateType(integer type) // Sets the inmate type. 0=Lilac, 1=Orange, 2=Red.
{
    vector inmateColor = llList2Vector([ // Int to corresponding color vector.
        <0.459, 0.239, 0.698>,
        <1.000, 0.502, 0.000>,
        <1.000, 0.118, 0.118>
    ], type);

    llSetLinkPrimitiveParamsFast(LINK_THIS, [ // Set undersuit color.
        PRIM_COLOR, 2, inmateColor, 1.0,
        PRIM_COLOR, 4, inmateColor, 1.0
    ]);
}

fixAlphas() // Fixes alpha blending bug. Threshhold=84.
{
    llSetLinkPrimitiveParamsFast(LINK_THIS, [
        PRIM_ALPHA_MODE, 1, PRIM_ALPHA_MODE_MASK, 84, // Logo text.
        PRIM_ALPHA_MODE, 3, PRIM_ALPHA_MODE_NONE, 0 // Pants portion.
    ]);
    llSetLinkPrimitiveParamsFast(2, [
        PRIM_ALPHA_MODE, ALL_SIDES, PRIM_ALPHA_MODE_MASK, 84 // Inmate number.
    ]);
}
