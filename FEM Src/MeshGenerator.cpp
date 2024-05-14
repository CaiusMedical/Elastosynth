//
// Created by mothership on 30/05/23.
//

#include "MeshGenerator.h"

Mesh MeshGenerator::GenerateMesh(CoordinateSystem *coordinate_system, Element* element) {

    // this portion generates grid matrices for spatial locations by doing a dot product between a linearly spaced array and a ones vector
    Mesh mesh = Mesh(coordinate_system, element);

    arma::mat axial_depth_grid = arma::linspace<arma::colvec>(coordinate_system->start_location[0],coordinate_system->start_location[0]+coordinate_system->depth,coordinate_system->axial_nodal_resolution)
                                      * arma::rowvec(coordinate_system->lateral_nodal_resolution,arma::fill::ones);

    arma::mat lateral_position_grid = arma::colvec(coordinate_system->axial_nodal_resolution,arma::fill::ones)
                                      * arma::linspace<arma::rowvec>(coordinate_system->start_location[1],coordinate_system->start_location[1]+coordinate_system->width,coordinate_system->lateral_nodal_resolution);
    arma::mat::iterator axial_depth_iterator = axial_depth_grid.begin();
    arma::mat::iterator lateral_position_iterator = lateral_position_grid.begin();


    // populate node array - these node iterators iterate over the node array, NOT the grid array
    arma::mat::col_iterator node_index_iterator = mesh.nodes.begin_col(0);
    arma::mat::col_iterator axial_node_iterator = mesh.nodes.begin_col(1);
    arma::mat::col_iterator lateral_node_iterator = mesh.nodes.begin_col(2);


    int node_index = 1;
    for(; node_index_iterator != mesh.nodes.end_col(0); ++node_index_iterator){

        *node_index_iterator = node_index;
        *axial_node_iterator = *axial_depth_iterator;
        *lateral_node_iterator = *lateral_position_iterator;

        axial_node_iterator++;
        axial_depth_iterator++;
        lateral_node_iterator++;
        lateral_position_iterator++;
        node_index++;
    }


    // Generate the elements
    if (element->no_nodes == 4){

        arma::umat::col_iterator node1_iterator = mesh.elements.begin_col(0);
        arma::umat::col_iterator node2_iterator = mesh.elements.begin_col(1);
        arma::umat::col_iterator node3_iterator = mesh.elements.begin_col(2);
        arma::umat::col_iterator node4_iterator = mesh.elements.begin_col(3);

        int alpha = 1; // This always represents the first node of the element
        for (; node1_iterator != mesh.elements.end_col(0); ++node1_iterator){


            if (alpha % coordinate_system->axial_nodal_resolution == 0 & alpha != 1) {
                alpha++;
            }

            *node1_iterator = alpha;
            *node2_iterator = alpha + 1;
            *node3_iterator = alpha + coordinate_system->axial_nodal_resolution + 1;
            *node4_iterator = alpha + coordinate_system->axial_nodal_resolution;

            node2_iterator++;
            node3_iterator++;
            node4_iterator++;
            alpha++;
        }


    }

    return mesh;

}

arma::mat MeshGenerator::GetNodes(CoordinateSystem* coordinate_system, std::string location) {

    int location_code = MapLocations(location);

    switch (location_code) {
        case 1:{
            arma::mat nodes = arma::mat(coordinate_system->lateral_nodal_resolution, 3, arma::fill::zeros);
            arma::mat::col_iterator node_iterator = nodes.begin_col(0);
            arma::mat::col_iterator axial_iterator = nodes.begin_col(1);
            arma::mat::col_iterator lateral_iterator = nodes.begin_col(2);

            int i = 0;
            for(; node_iterator != nodes.end_col(0); ++node_iterator){

                *node_iterator = i*(coordinate_system->axial_nodal_resolution) + 1;
                *axial_iterator = coordinate_system->start_location[0];
                *lateral_iterator = coordinate_system->start_location[1] + i*(coordinate_system->width/(coordinate_system->lateral_nodal_resolution - 1));

                axial_iterator++;
                lateral_iterator++;
                i++;
            }
            return nodes;
        }

        case 2:{
            arma::mat nodes = arma::mat(coordinate_system->lateral_nodal_resolution, 3, arma::fill::zeros);
            arma::mat::col_iterator node_iterator = nodes.begin_col(0);
            arma::mat::col_iterator axial_iterator = nodes.begin_col(1);
            arma::mat::col_iterator lateral_iterator = nodes.begin_col(2);

            int i = 0;
            for(; node_iterator != nodes.end_col(0); ++node_iterator){

                *node_iterator = (i+1)*(coordinate_system->axial_nodal_resolution);
                *axial_iterator = coordinate_system->start_location[0] + coordinate_system->start_location[0] + coordinate_system->depth;
                *lateral_iterator = coordinate_system->start_location[1] + i*(coordinate_system->width/(coordinate_system->lateral_nodal_resolution - 1));

                axial_iterator++;
                lateral_iterator++;
                i++;
            }
            return nodes;
        }

        case 3:{
            arma::mat nodes = arma::mat(coordinate_system->axial_nodal_resolution, 3, arma::fill::zeros);
            arma::mat::col_iterator node_iterator = nodes.begin_col(0);
            arma::mat::col_iterator axial_iterator = nodes.begin_col(1);
            arma::mat::col_iterator lateral_iterator = nodes.begin_col(2);

            int i = 0;
            for(; node_iterator != nodes.end_col(0); ++node_iterator){

                *node_iterator = (i+1);
                *axial_iterator = coordinate_system->start_location[0] + i*(coordinate_system->depth / (coordinate_system->axial_nodal_resolution - 1));
                *lateral_iterator = coordinate_system->start_location[1];

                axial_iterator++;
                lateral_iterator++;
                i++;
            }
            return nodes;
        }

        case 4:{
            arma::mat nodes = arma::mat(coordinate_system->axial_nodal_resolution, 3, arma::fill::zeros);
            arma::mat::col_iterator node_iterator = nodes.begin_col(0);
            arma::mat::col_iterator axial_iterator = nodes.begin_col(1);
            arma::mat::col_iterator lateral_iterator = nodes.begin_col(2);

            int i = 0;
            for(; node_iterator != nodes.end_col(0); ++node_iterator){

                *node_iterator = (coordinate_system->lateral_nodal_resolution - 1)*coordinate_system->axial_nodal_resolution + i + 1;
                *axial_iterator = coordinate_system->start_location[0] + i*(coordinate_system->depth / (coordinate_system->axial_nodal_resolution - 1));
                *lateral_iterator = coordinate_system->start_location[1] + coordinate_system->width;

                axial_iterator++;
                lateral_iterator++;
                i++;
            }
            return nodes;
        }

    }

}

int MeshGenerator::MapLocations(std::string const& location) {
    if (location == "top") return 1;
    else if (location == "bottom") return 2;
    else if (location == "left") return 3;
    else if (location == "right") return 4;
    return -1;
}