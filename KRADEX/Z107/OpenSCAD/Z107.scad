$fn = 40; // Wyższa rozdzielczość dla ładnych, okrągłych otworów

// --- PARAMETRY GŁÓWNE OBUDOWY Z107 ---
mod_width = 52.6;         // Szerokość obudowy wzdłuż szyny DIN (oś Z)
wall_thickness = 2;     // Grubość ścianki korpusu


third_block_w = 45.6;
third_block_h = 51.1;
first_block_w = 90;
first_block_h = third_block_h-32.35;
second_block_w = 67.85;
second_block_h = third_block_h-15.6;

// --- PARAMETRY TERMINALI (Rysunek 2) ---
// Strona Lewa (6 otworów)
left_count = 6;
left_dia = 4.8;
left_pitch = 7.58;
left_x_pos = -33.3;       // Pozycja osi otworów na lewej półce

// Strona Prawa (9 otworów)
right_count = 9;
right_dia = 3.8;
right_pitch = 5;
right_x_pos = 33.3;       // Pozycja osi otworów na prawej półce

// --- MODUŁY GEOMETRYCZNE ---

module profil_korpusu_2d() {
    // Odzwierciedlenie schodkowego kształtu obudowy (Wymiary z przekroju A-A)
    union() {
        // Dolna najszersza sekcja
        translate([-first_block_w / 2, 0]) square([first_block_w, first_block_h]); 
        
        // Środkowa sekcja
        translate([-second_block_w / 2, 0]) square([second_block_w, second_block_h]);
        
        // Górna najwęższa sekcja (czołowa)
        translate([-third_block_w / 2, 0]) square([third_block_w, third_block_h]);
    }
}

module profil_korpusu_2_schody() {
    union() {
        // Dolna najszersza sekcja
        translate([-first_block_w / 2, 0]) square([first_block_w, first_block_h]); 
        
        // Środkowa sekcja
        translate([-second_block_w / 2, 0]) square([second_block_w, second_block_h]);
    }
}

module korpus_3d_pusty() {
    // Generowanie bryły i jej wydrążenie ścianką o grubości 1.5mm
    difference() {
        // Zewnętrzny płaszcz
        linear_extrude(height = mod_width, center = true)
        profil_korpusu_2d();
        
        // Wewnętrzne wybranie
        union() {
            //translate([0, -1, 0]) // Lekkie przesunięcie w dół dla czystego cięcia bazy
            linear_extrude(height = mod_width - (wall_thickness * 2), center = true)
            offset(r = -wall_thickness)
            profil_korpusu_2_schody();
            
            linear_extrude(height = mod_width - (wall_thickness * 2), center = true)
            offset(r = -wall_thickness) 
            translate([-first_block_w/2, -2]) square([first_block_w, first_block_h]);
        }
    }
}

module korpus_okienko() {
    okienko_rant_size_x = 37.75;
    okienko_rant_size_z = 43.7;
    okienko_front_size_x = 41.75;
    okienko_front_size_z = 47.8;
    
    
    union() {
        #translate([0, 46.9, 0])
        rotate([90, 0, 0])
        linear_extrude(height=56.6, center=true) // 1.6
        square([okienko_rant_size_x, okienko_rant_size_z], center=true);
        
        #translate([0, 48.5, 0])
        rotate([90, 0, 0])
        linear_extrude(height=5, center=true)
        square([okienko_front_size_x, okienko_front_size_z], center=true);
    }
    
}

module okragle_wyciecia_terminali() {
    // 1. STRONA LEWA: 6 otworów (Ø 4.8, pitch 7.58)
    left_total_span = (left_count - 1) * left_pitch;
    // Wyznaczamy wysokość Y środka pionowej ścianki pierwszego schodka
    left_y_pos = first_block_h / 2;
    
    // Wyznaczenie pozycji otworow w osi X (7.4mm od scianki)
    left_x_pos = -((first_block_w / 2) - 7.4);
    
    translate([left_x_pos, left_y_pos, 0]) {
        for (i = [0 : left_count - 1]) {
            // Rozmieszczenie otworów wzdłuż długości obudowy (oś Z)
            translate([0, 0, -left_total_span / 2 + (i * left_pitch)])
            // Obrót wokół osi X, aby cylinder ciął poziomo wzdłuż osi Y
            rotate([270, 0, 0])
            cylinder(h = left_y_pos+1, d = left_dia, center = false);
        }
    }
    
    // 2. STRONA PRAWA: 9 otworów (Ø 3.8, pitch 5)
    right_total_span = (right_count - 1) * right_pitch;
    // Wyznaczamy wysokość Y środka pionowej ścianki drugiego schodka
    right_y_pos = first_block_h / 2;
    
    // Wyznaczamy pozycje otworow w osi X (7.3mm od ścianki)
    right_x_pos = (first_block_w/2)-7.3;
    
    translate([right_x_pos, right_y_pos, 0]) {
        for (i = [0 : right_count - 1]) {
            // Rozmieszczenie otworów wzdłuż długości obudowy (oś Z)
            translate([0, 0, -right_total_span / 2 + (i * right_pitch)])
            // Obrót wokół osi X, aby cylinder ciął poziomo wzdłuż osi Y
            rotate([270, 0, 0])
            color("red")
            cylinder(h = right_y_pos+1, d = right_dia, center = false);
        }
    }
}

module korpus() {
    difference() {
        korpus_3d_pusty();        
        union() {
            okragle_wyciecia_terminali();
            korpus_okienko();
        }
    }
}

// ================================================================
// --- PODSTAWA ZATRZASKOWA ---
profil_podstawy_y = 17.7;//22.35;
profil_podstawy_X = 89.85;
profil_podstawy_x = 85.9;
profil_podstawy_zewn_wspor_x = 86.15;
profil_podstawy_zewn_wspor_y = 86.15;
profil_podstawy_internal_x = 82.4;
profil_podstawy_internal_y = 7.15;

module profil_podstawy_2d() {
    // Profil boczny podstawy z uwzglednieniem wyciecia na szyne DIN
    square([profil_podstawy_X, profil_podstawy_y]);
}

module profil_podstawy_zewnetrzna_fazka() {
        zewn_wyciecie_L = 8.35;
        zewn_wyciecie_l = 4.75;
        zewn_wyciecie_h = 1.975+1;
        translate([profil_podstawy_x/2, 0, 0])
        polygon(points=[[0,0], [zewn_wyciecie_h, 0], [zewn_wyciecie_h,zewn_wyciecie_L], [0, zewn_wyciecie_l]]);
}

module profil_podstawy_wyciecie_DIN() {
//    square([35.9, 5.1]);
    polygon(points=[[35.9,0], [35.9, 5.1], [0, 5.1], [0,4.1],[0.55+1.85,3],[0.55,0],[0,0]]);
}

module profil_podstawy_mocowanie_1() {
    difference() {
        moc_rot = -90;
        rotate([moc_rot, 0, 0])
        cylinder(h=8.85, d=6, center = false);
        rotate([moc_rot, 0, 0])
        cylinder(h=8.85, d=2.4, center = false);
    }
}

module profil_podstawy_mocowanie_2() {
    difference() {
        moc_rot = -90;
        rotate([moc_rot, 0, 0])
        cylinder(h=8.9, d=6, center = false);
        rotate([moc_rot, 0, 0])
        cylinder(h=8.9, d=2.4, center = false);
    }
}


module profil_podstawy_korpus() {
    union() {
        difference() {
            union() {
                linear_extrude(height=mod_width, center = true)
                translate([-profil_podstawy_X/2, 0, 0])
                profil_podstawy_2d();
                
                
                
                
            }
            
            intersection() {
            
                union() {
                    linear_extrude(height = mod_width, center = true)
                    translate([-(profil_podstawy_x/2)+25, 0, 0])
                    profil_podstawy_wyciecie_DIN();
                    linear_extrude(height = mod_width, center = true)
                    profil_podstawy_zewnetrzna_fazka();
                    mirror([1,0,0])
                    linear_extrude(height = mod_width, center = true)
                    profil_podstawy_zewnetrzna_fazka();
                    
                    linear_extrude(height = mod_width - (wall_thickness * 2), center = true)
                    translate([-(profil_podstawy_x/2), 6.9, 0])
                    square([profil_podstawy_internal_x, profil_podstawy_y]);
                    
                    linear_extrude(height = mod_width - (wall_thickness * 2), center = true)
                    translate([-(profil_podstawy_x/2)+1.8, 1.85, 0])
                    square([21.25,12.2]);
                    
                    linear_extrude(height = mod_width - (wall_thickness * 2), center = true)
                    translate([-(profil_podstawy_x/2)+63, 1.85, 0])
                    square([21.3,12.2]);
                }
            }
        }        
                
        // mocowanie sruby
        translate([-(profil_podstawy_x/2)+17.85, 1.80, mod_width/2-10.45])
        profil_podstawy_mocowanie_1();
        translate([(profil_podstawy_x/2)-18, 1.80, -(mod_width/2)+10.1])
        profil_podstawy_mocowanie_2();
    }
}


module prowadnice_pcb() {
    // Wewnętrzne sloty na pionowy montaż płytek (z przekroju B-B)
    for (m = [0, 1]) {
        mirror([m, 0, 0]) {
            translate([(41.3 / 2) - wall_thickness - 1.2, 20, -mod_width/2])
            cube([1.2, 25, mod_width]);
        }
    }
}

// --- ZŁOŻENIE KOŃCOWE KORPUSU ---
module caly_model() {
    union() {
        korpus();
        translate([0, -51, 0])
        profil_podstawy_korpus();
    }
}



////projection(cut = true)
//rotate([0, 90, 0])
caly_model();
