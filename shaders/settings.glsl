//--// Miscellaneous

#define EXPOSURE 0.15

//#define TEMPORAL_AA

#define COMPOSITE0_SCALE 1.0 // [0.5 1.0]

//--// Lighting

#define SHADOWS_MODE 1 // [0 1]
const int shadowMapResolution = 2048; // [1024 2048 4096 8192]

#define CAUSTICS_SAMPLES        9   // SEUS V11 = 9   [0 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50]
#define CAUSTICS_RADIUS         0.3 // SEUS V11 = 0.2 [0.2 0.3 0.4]
#define CAUSTICS_DEFOCUS        1.0 // SEUS V11 = 1.5 [1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CAUSTICS_DISTANCE_POWER 1.0 // SEUS V11 = 1.0 [1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#define CAUSTICS_RESULT_POWER   1.0 // SEUS V11 = 2.0 [1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define RSM_SAMPLES     12 // [0 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50]
#define RSM_RADIUS     4.0 // [4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0]
#define RSM_BRIGHTNESS 1.0 // [1.0 2.0 3.0 4.0 5.0]

//--// Optics

#define APERTURE_RADIUS          0.05 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09]
#define APERTURE_BLADE_COUNT     7    // [3 4 5 6 7 8 9 10 11]
#define APERTURE_BLADE_ROTATION 10    //

#define GLARE_AMOUNT 0.05 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15]

//--// Set based on the above //----------------------------------------------//

// With TAA biasing the texture lod by -1 we can effectively get a small amount of anisotropic filtering
#ifdef TEMPORAL_AA
#define LOD_BIAS -1.0
#else
#define LOD_BIAS 0.0
#endif
