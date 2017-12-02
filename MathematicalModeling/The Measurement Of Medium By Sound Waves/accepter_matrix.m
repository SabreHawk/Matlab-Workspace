function accepter_matrix = accepter_matrix
    accepter_matrix = zeros(1,3);
    counter = 1;
    for x = -20 : 20
        for y = -10 : 10
            if( (1 - y^2 / 100 - x^2 / 400) >= 0)
            z_up = 100 * sqrt( 1 - y^2 / 100 - x^2 / 400 );
            z_bottom = -z_up;
            accepter_matrix(counter,:) = [x , y ,z_up];
            accepter_matrix(counter+1 , :) = [x , y , z_bottom];
            counter = counter + 2;
            end
        end
    end
end