# Procedural Terrain Generation Guide

## 🏔️ Overview

The game now features **Minecraft-style procedural terrain generation** with:
- **Perlin noise-based** height variation
- **Stepped terrain** (height snaps to 2-unit increments)
- **Low poly trees** (3-cone pine style)
- **Low poly buildings** (3 different types)
- **Full collision** on all generated geometry

## 🎮 Terrain Generation

### Algorithm
- Uses `FastNoiseLite` with Perlin noise
- 100x100 grid (configurable via `terrain_size`)
- Height range: 0-15 units (configurable via `terrain_height`)
- **Stepped height**: `floor(height / 2.0) * 2.0` for blocky look
- Triangle mesh with auto-generated normals

### Parameters (Editable in Scene)
```gdscript
terrain_size = 100       # Grid size (100x100)
terrain_height = 15.0    # Max height variation
noise_frequency = 0.05   # Detail level
tree_density = 0.03      # Trees per square unit
building_count = 6       # Total buildings spawned
```

## 🌲 Low Poly Trees

### Design
- **Trunk**: 6-sided cylinder (0.3-0.4 units radius, 4 units tall)
  - Brown color (#4C403)
  - Positioned at y = 2.0
- **Foliage**: 3 stacked cones (6-sided)
  - Dark green (#264019)
  - Sizes: 2.0 → 1.7 → 1.4 units radius
  - Heights: 3.5, 5.0, 6.5 units

### Spawning Logic
- Only spawns on elevated terrain (y > 2.0)
- Random distribution across terrain
- Density controlled by `tree_density` parameter
- Auto-positioned on terrain height

## 🏠 Low Poly Buildings

### Three Building Types

#### 1. **Cabin** (Simple House)
- **Walls**: 6x4x6 box
  - Beige/brown color (#665933)
- **Roof**: 7x2x7 prism
  - Dark brown (#3F332E)
  - Rotated 90° for proper alignment
- **Total Height**: ~6 units

#### 2. **Tower** (Communication/Watch Tower)
- **Base**: 4x3x4 box
  - Gray color (#595966)
  - Metallic finish (30%)
- **Body**: Tapered cylinder (10 units tall)
  - 8-sided
  - Metallic gray
  - Radius: 1.5 → 1.2
- **Top**: Cone cap (2 units)
  - Darker gray
  - Metallic (50%)
- **Total Height**: ~15 units

#### 3. **Warehouse** (Storage Building)
- **Main building**: 10x5x8 box
  - Light gray (#726A66)
- **Roof**: 10.5x0.5x8.5 flat box
  - Dark gray (#4C4742)
- **Total Height**: ~5.5 units

### Placement
- Random rotation (0-360°)
- Within central 2/3 of terrain
- Auto-positioned on terrain height
- Count controlled by `building_count`

## 🎯 Integration with Game Systems

### Player Positioning
The player automatically positions on terrain at start:
```gdscript
# In first_person_controller.gd
await get_tree().create_timer(0.6).timeout
_position_on_terrain()  # Queries terrain height
```

### Tower Positioning
Towers auto-position on terrain after generation:
```gdscript
# In tower.gd
auto_position_on_terrain = true  # Enabled by default
await get_tree().create_timer(0.5).timeout
_position_on_terrain()
```

### Terrain Height Query
Any script can query terrain height:
```gdscript
var terrain = get_node("/root/Main/TerrainGenerator")
var height = terrain.get_terrain_height_at(x, z)
```

## 🛠️ Customization

### Changing Terrain Style

**More Smooth/Natural:**
```gdscript
terrain_height = 20.0
noise_frequency = 0.03
# Comment out: height = floor(height / 2.0) * 2.0
```

**More Extreme/Mountainous:**
```gdscript
terrain_height = 25.0
noise_frequency = 0.08
```

**Flatter (Desert-like):**
```gdscript
terrain_height = 8.0
noise_frequency = 0.02
```

### Adding More Trees
```gdscript
tree_density = 0.05  # More trees
```

### Adding More Buildings
```gdscript
building_count = 12  # More buildings
```

### New Building Type
Add to `_create_low_poly_building()`:
```gdscript
match building_type:
    0: building = _create_cabin()
    1: building = _create_tower_building()
    2: building = _create_warehouse()
    3: building = _create_your_new_building()  # Add this
```

Then update the random selection:
```gdscript
var building_type = randi() % 4  # Change to 4 types
```

## 📊 Performance

### Current Stats
- **Terrain**: 100x100 grid = 20,000 triangles
- **Trees**: ~300 trees at 0.03 density = ~3,600 triangles
- **Buildings**: 6 buildings = ~300 triangles
- **Total**: ~24,000 triangles (very lightweight)

### Optimization Tips
1. **Reduce terrain size** for better performance:
   ```gdscript
   terrain_size = 80  # Smaller area
   ```

2. **Reduce tree density** on low-end hardware:
   ```gdscript
   tree_density = 0.015  # Half the trees
   ```

3. **LOD for distant objects** (future enhancement):
   - Swap distant trees/buildings for billboards
   - Reduce triangle count at distance

## 🎨 Visual Enhancement Ideas

### Better Materials
Replace basic materials with:
- **PBR textures** for wood/metal
- **Normal maps** for detail
- **Emission** for glowing windows at night

### Varied Trees
Currently all pine trees. Add:
- Deciduous trees (sphere canopy)
- Dead/winter trees (no foliage)
- Different sizes (scale variation)

### Building Detail
- Add windows (darker quad meshes)
- Add doors (different colored faces)
- Chimneys on cabins
- Antennas on towers

### Color Variation
Add random color variation:
```gdscript
var color_var = randf_range(0.9, 1.1)
material.albedo_color *= Color(color_var, color_var, color_var)
```

---

**The procedural system generates a unique world every time while maintaining performance!**

All buildings and trees are properly positioned on the terrain and towers automatically adapt to the generated landscape.
