 Main Entry Point

  The app uses wxWidgets — there's no traditional main(). Instead, the macro IMPLEMENT_APP(wxraytracerapp) in UserInterface/wxraytracer.cpp generates the entry point. The startup chain
  is:

  1. wxraytracerapp::OnInit() — creates the window, calls renderStart()
  2. RenderCanvas::renderStart() — creates World, calls build(), spawns render thread
  3. RenderThread::Entry() — calls world->render_scene()

  Rendering Flow (per pixel)

  render_scene() → create Ray (orthographic)
      → tracer_ptr->trace_ray(ray)        [Strategy: MultipleObjects]
          → world->hit_bare_bones_objects(ray)
              → loop all objects: obj->hit(ray, t, sr)  [Virtual: Sphere/Plane]
                  → solve quadratic (sphere) or plane equation
              → return closest hit ShadeRec
          → return sr.color or background_color
      → display_pixel() → gamma correct → setPixel() to GUI

  Key Architecture

  - 39 source files across 7 directories
  - Strategy pattern for tracers, Template Method for geometric objects
  - World is the central facade connecting everything
  - Currently bare-bones: no materials, no lights — just object colors

  The full graph with file paths and line numbers is in the plan file.

● User approved Claude's plan
  ⎿  Plan saved to: ~/.claude/plans/peaceful-hopping-garden.md · /plan to edit
     Ray Tracing From the Ground Up - Code Flow Analysis

     Context

     This is a skeleton C++ ray tracer based on the book "Ray Tracing from the Ground Up". It uses wxWidgets for the GUI and implements an orthographic camera with bare-bones rendering
     (no lighting/materials yet). The user requested a code flow graph with the main entry point highlighted.

     Project Structure

     source/
     ├── UserInterface/        # wxWidgets app (ENTRY POINT)
     │   ├── wxraytracer.cpp   # App init, render thread, canvas
     │   └── wxraytracer.h
     ├── World/                # Scene management
     │   ├── World.cpp/h       # Central orchestrator, render loop
     │   └── ViewPlane.cpp/h   # Image resolution, pixel size, gamma
     ├── Tracers/              # Ray tracing algorithms (Strategy pattern)
     │   ├── Tracer.cpp/h      # Abstract base class
     │   ├── SingleSphere.cpp/h
     │   └── MultipleObjects.cpp/h
     ├── GeometricObjects/     # Renderable primitives (Template Method pattern)
     │   ├── GeometricObject.cpp/h  # Abstract base class
     │   ├── Sphere.cpp/h
     │   └── Plane.cpp/h
     ├── Utilities/            # Math primitives
     │   ├── Ray.h             # Point3D origin + Vector3D direction
     │   ├── Vector3D.cpp/h    # 3D vector with dot/cross product
     │   ├── Point3D.cpp/h     # 3D point
     │   ├── Normal.cpp/h      # Surface normal
     │   ├── RGBColor.cpp/h    # Float RGB color
     │   ├── ShadeRec.cpp/h    # Ray-hit intersection record
     │   ├── Matrix.cpp/h      # 4x4 transformation matrix
     │   ├── Constants.h       # kEpsilon, kHugeValue, colors
     │   └── Maths.h           # Math utilities
     ├── Window/
     │   └── Window.cpp/hpp    # Graphics window wrapper
     ├── build/                # Scene definitions
     │   ├── BuildSingleSphere.cpp
     │   ├── BuildMultipleObjects.cpp
     │   └── BuildBBCoverPic.cpp
     └── Main/                 # Empty (unused)

     Code Flow Graph

     ╔══════════════════════════════════════════════════════════════════════╗
     ║                     MAIN ENTRY POINT                                 ║
     ║          UserInterface/wxraytracer.cpp                               ║
     ║                                                                      ║
     ║   IMPLEMENT_APP(wxraytracerapp)   <-- wxWidgets macro = main()       ║
     ║          │                                                           ║
     ║          ▼                                                           ║
     ║   wxraytracerapp::OnInit()                                           ║
     ║          │                                                           ║
     ║          ├─ Create wxraytracerFrame (window)                         ║
     ║          └─ frame->canvas->renderStart()                             ║
     ╚══════════════════════════════════════════════════════════════════════╝
                         │
                         ▼
       ┌─────────────────────────────────────┐
       │  RenderCanvas::renderStart()        │
       │  (UserInterface/wxraytracer.cpp)    │
       │                                     │
       │  1. world = new World()             │
       │  2. world->build()  ──────────────────────┐
       │  3. thread = new RenderThread(world)│      │
       │  4. thread->Run()                   │      │
       └─────────┬───────────────────────────┘      │
                 │                                  │
                 │                                  ▼
                 │           ┌───────────────────────────────────────────┐
                 │           │  World::build()                           │
                 │           │  (build/BuildBBCoverPic.cpp)              │
                 │           │                                           │
                 │           │  1. Configure ViewPlane (hres, vres, s)   │
                 │           │  2. Set background_color                  │
                 │           │  3. Create Tracer:                        │
                 │           │     tracer_ptr = new MultipleObjects(this)│
                 │           │  4. Create GeometricObjects:              │
                 │           │     Sphere* s = new Sphere(center, r)     │
                 │           │     s->set_color(RGBColor(...))           │
                 │           │     add_object(s)  // x32 spheres         │
                 │           └───────────────────────────────────────────┘
                 │
                 ▼
       ┌─────────────────────────────────────┐
       │  RenderThread::Entry()              │
       │  (UserInterface/wxraytracer.cpp)    │
       │                                     │
       │  world->render_scene()              │
       └─────────┬───────────────────────────┘
                 │
                 ▼
       ┌─────────────────────────────────────────────────────────────────┐
       │  World::render_scene()                                          │
       │  (World/World.cpp:59-77)                                        │
       │                                                                 │
       │  FOR each pixel (row r, col c):                                 │
       │  ┌──────────────────────────────────────────────────────────┐   │
       │  │  1. Construct Ray:                                       │   │
       │  │     ray.o = Point3D(s*(c-hres/2+0.5), s*(r-vres/2+0.5),  │   │
       │  │                     100.0)    // orthographic camera     │   │
       │  │     ray.d = Vector3D(0, 0, -1) // looking into scene     │   │
       │  │                                                          │   │
       │  │  2. pixel_color = tracer_ptr->trace_ray(ray)  ──────┐    │   │
       │  │                                                     │    │   │
       │  │  3. display_pixel(r, c, pixel_color)  ───────────┐  │    │   │
       │  └──────────────────────────────────────────────┼───┼──┘    │
       └─────────────────────────────────────────────────┼───┼───────┘
                                                         │   │
                           ┌─────────────────────────────┘   │
                           ▼                                 │
       ┌───────────────────────────────────────────┐         │
       │  MultipleObjects::trace_ray(ray)          │         │
       │  (Tracers/MultipleObjects.cpp:25-33)      │         │
       │                                           │         │
       │  sr = world->hit_bare_bones_objects(ray) ──────┐    │
       │                                           │    │    │
       │  if (sr.hit_an_object)                    │    │    │
       │      return sr.color   // object color    │    │    │
       │  else                                     │    │    │
       │      return background_color  // black    │    │    │
       └───────────────────────────────────────────┘    │    │
                                                        │    │
                           ┌────────────────────────────┘    │
                           ▼                                 │
       ┌───────────────────────────────────────────────┐     │
       │  World::hit_bare_bones_objects(ray)           │     │
       │  (World/World.cpp:144-160)                    │     │
       │                                               │     │
       │  tmin = kHugeValue (infinity)                 │     │
       │                                               │     │
       │  FOR each GeometricObject* in objects:        │     │
       │  ┌─────────────────────────────────────────┐  │     │
       │  │  if obj->hit(ray, t, sr) && t < tmin:   │  │     │
       │  │      tmin = t                           │  │     │
       │  │      sr.hit_an_object = true            │  │     │
       │  │      sr.color = obj->get_color()        │  │     │
       │  └──────────────┬──────────────────────────┘  │     │
       │                 │                             │     │
       │  return sr (closest hit)                      │     │
       └─────────────────┼─────────────────────────────┘     │
                         │                                   │
                         ▼                                   │
       ┌──────────────────────────────────────────┐          │
       │  Sphere::hit(ray, tmin, sr)              │          │
       │  (GeometricObjects/Sphere.cpp:68-102)    │          │
       │                                          │          │
       │  Solve quadratic: at² + bt + c = 0       │          │
       │    a = ray.d · ray.d                     │          │
       │    b = 2(ray.o - center) · ray.d         │          │
       │    c = |ray.o - center|² - radius²       │          │
       │    disc = b² - 4ac                       │          │
       │                                          │          │
       │  if disc < 0: return false (miss)        │          │
       │  else: find smallest positive t          │          │
       │    sr.normal = normalized hit normal     │          │
       │    sr.local_hit_point = ray.o + t*ray.d  │          │
       │    return true (hit!)                    │          │
       └──────────────────────────────────────────┘          │
                                                             │
                           ┌─────────────────────────────────┘
                           ▼
       ┌───────────────────────────────────────────┐
       │  World::display_pixel(row, col, color)    │
       │  (World/World.cpp:120-139)                │
       │                                           │
       │  1. Clamp/normalize color to [0,1]        │
       │  2. Apply gamma correction (pow curve)    │
       │  3. Flip Y-axis for screen coords         │
       │  4. Convert to 0-255 int range            │
       │  5. paintArea->setPixel(x, y, r, g, b)    │
       │     └─> Updates wxWidgets canvas          │
       └───────────────────────────────────────────┘

     Class Hierarchy

     GeometricObject (abstract)          Tracer (abstract)
     ├── Sphere                          ├── SingleSphere
     └── Plane                           └── MultipleObjects

     wxApp
     └── wxraytracerapp (entry point)

     World  ──owns──>  Tracer*
            ──owns──>  vector<GeometricObject*>
            ──owns──>  ViewPlane
            ──uses──>  ShadeRec, Ray, RGBColor

     Key Design Patterns

     - Strategy Pattern: World holds a Tracer* — swappable ray tracing algorithms
     - Template Method: GeometricObject defines hit() and clone() as pure virtual
     - Facade: World is the central coordinator connecting all subsystems

     No Implementation Needed

     This is a read-only analysis task. The plan file serves as the deliverable — the code flow graph above.

● The analysis is complete. Here's a quick recap of the key findings:

  Main Entry Point

  UserInterface/wxraytracer.cpp — the IMPLEMENT_APP(wxraytracerapp) macro generates main(). The wxWidgets framework calls OnInit() which creates the window and kicks off rendering in a
  background thread.

  Execution Flow (top to bottom)

  wxraytracerapp::OnInit()
    → RenderCanvas::renderStart()
      → World::build()           // create scene (32 spheres)
      → RenderThread::Entry()
        → World::render_scene()  // per-pixel loop
          → Tracer::trace_ray()  // strategy pattern dispatch
            → World::hit_bare_bones_objects()  // test all objects
              → Sphere::hit() / Plane::hit()  // quadratic solve
            → return color
          → display_pixel()      // gamma correct → GUI

  Architecture

  - 39 source files in 7 directories
  - Strategy pattern for swappable tracers (SingleSphere, MultipleObjects)
  - Template Method for geometric objects (Sphere, Plane)
  - World acts as the central facade
  - Currently a bare-bones renderer — no materials or lighting, just flat object colors

  The full detailed graph with box diagrams, file paths, and line numbers is saved in the plan file if you want to reference it later.
