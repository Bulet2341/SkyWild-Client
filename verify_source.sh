#!/bin/bash
echo "=== Eaglercraft Source Verification ==="
echo ""

JAVA_COUNT=$(find . -name "*.java" 2>/dev/null | wc -l)
echo "Java files found: $JAVA_COUNT"

if [ $JAVA_COUNT -lt 100 ]; then
    echo "⚠️  WARNING: Less than 100 Java files - may be incomplete!"
else
    echo "✓ Good amount of Java files"
fi

echo ""
echo "=== Key Files Check ==="

FILES=(
    "Minecraft.java"
    "EntityPlayerSP.java"
    "GuiIngame.java"
    "EntityRenderer.java"
    "NetHandlerPlayClient.java"
)

for file in "${FILES[@]}"; do
    if find . -name "$file" | grep -q .; then
        echo "✓ Found: $file"
    else
        echo "✗ Missing: $file"
    fi
done

echo ""
echo "=== Directory Structure ==="
find . -type d -maxdepth 3 | head -30
