function New-UDSkeleton {
    <#
    .SYNOPSIS
    Creates a loading skeleton
    
    .DESCRIPTION
    Creates a loading skeleton
    
    .PARAMETER Id
    The ID of this component.
    
    .PARAMETER Variant
    The type of skeleton to display. 
    
    .PARAMETER Height
    The static height of the skeleton.
    
    .PARAMETER Width
    The static width of the skeleton.
    
    .PARAMETER Animation
    The type of animation to use for the skeleton.
    #>
    param(
        [Parameter()]
        [String]$Id = ([Guid]::NewGuid()),
        [Parameter()]
        [ValidateSet("text", "rect", "circle")]
        [string]$Variant = 'text',
        [Parameter()]
        [int]$Height,
        [Parameter()]
        [int]$Width,
        [Parameter()]
        [ValidateSet("wave", "disabled", "pulsate")]
        [string]$Animation = "pulsate"
    )

    @{
        type = "mu-skeleton"
        id = $Id 
        isPlugin = $true
        assetId = $MUAssetId

        variant = $Variant.ToLower()
        height = $Height
        width = $Width 
        animation = $Animation.ToLower()
    }
}