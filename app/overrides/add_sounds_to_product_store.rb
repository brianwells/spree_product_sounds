Deface::Override.new(:virtual_path => "spree/products/show", 
                     :name => "add_sounds_to_product_store",
                     :insert_after => "[data-hook='product_properties'], #product_properties[data-hook]",
                     :partial => "spree/products/product_sounds",
                     :disabled => false)
