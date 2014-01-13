Deface::Override.new(:virtual_path => "spree/admin/shared/_product_tabs", 
                     :name => "add_sounds_to_product_sidebar",
                     :insert_bottom => "[data-hook='admin_product_tabs'],#admin_product_tabs[data-hook]", 
                     :partial => "spree/admin/products/sounds",
                     :disabled => false)
