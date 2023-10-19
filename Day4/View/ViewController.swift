//
//  ViewController.swift
//  Day4
//
//  Created by P090MMCTSE011 on 19/10/23.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pokemonTable: UITableView!
    
    var pokemons: [PokemonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonTable.register(UINib(
            nibName: "PokemonTableViewCell",
            bundle: nil
        ), forCellReuseIdentifier: "pokemonTableCell")
        
        pokemonTable.delegate = self
        pokemonTable.dataSource = self
        
//        self.deleteAll()
        self.getPokemon()
    }
    
    @IBAction func addBtnClick(_ sender: Any) {
        let alert = UIAlertController(title: "New Pokemon", message: "Please Fill the Form", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {tf in tf.placeholder = "Name"})
        alert.addTextField(configurationHandler: {tf in tf.placeholder = "Type"})
        
        alert.addAction(UIAlertAction(title: "Add Pokemon", style: .default, handler: {
            action in
            
            if alert.textFields![0].text!.isEmpty || alert.textFields![1].text!.isEmpty {
                let warning = UIAlertController(title: "Warning", message: "Value Cannot be Empty", preferredStyle: .alert)
                warning.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(warning, animated: true)
            } else {
                self.createPokemon(name: alert.textFields![0].text!, type: alert.textFields![1].text!)
                
                let success = UIAlertController(title: "Success", message: "Pokemon Created", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(success, animated: true)
                self.getPokemon()
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonTableCell", for: indexPath) as! PokemonTableViewCell
        
        cell.nameLabel.text = self.pokemons[indexPath.row].name
        cell.typeLabel.text = self.pokemons[indexPath.row].type
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editPokemon(index: indexPath.row)
    }
    
    func createPokemon(name: String, type: String) {
        let id = UserDefaults.standard.integer(forKey: "id")
        UserDefaults.standard.setValue(id + 1, forKey: "id")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let pokemonEntity = NSEntityDescription.entity(forEntityName: "Pokemon", in: managedContext)
                
        let insert = NSManagedObject(
            entity: pokemonEntity!,
            insertInto: managedContext
        )
        insert.setValue(id, forKey: "id")
        insert.setValue(name, forKey: "name")
        insert.setValue(type, forKey: "type")
        
        do {
            try managedContext.save()
        } catch let err {
            print("Error in Save \(err)")
        }
    }
    
    func getPokemon() {
        self.pokemons = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                entityName: "Pokemon"
        )
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            result.forEach{pokemon in
                self.pokemons.append(
                    PokemonModel(
                        id: pokemon.value(forKey: "id") as! Int64,
                        name: pokemon.value(forKey: "name") as! String,
                        type: pokemon.value(forKey: "type") as! String
                    )
                )
            }
        } catch let err {
            print("Error in Read \(err)")
        }
        
        self.pokemonTable.reloadData()
    }
    
    func editPokemon(index: Int) {
        let alert = UIAlertController(title: "Edit Pokemon", message: "Please Fill the Form", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Name"
            tf.text = self.pokemons[index].name
            tf.isUserInteractionEnabled = false
        })
        alert.addTextField(configurationHandler: {tf in
            tf.placeholder = "Type"
            tf.text = self.pokemons[index].type
        })
        
        alert.addAction(UIAlertAction(title: "Edit Pokemon", style: .default, handler: {
            action in
            
            if alert.textFields![0].text!.isEmpty || alert.textFields![1].text!.isEmpty {
                let warning = UIAlertController(title: "Warning", message: "Value Cannot be Empty", preferredStyle: .alert)
                warning.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(warning, animated: true)
            } else {
                self.updatePokemon(id: self.pokemons[index].id, name: alert.textFields![0].text!, type: alert.textFields![1].text!)
                
                let success = UIAlertController(title: "Success", message: "Pokemon Edited", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(success, animated: true)
                self.getPokemon()
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    func updatePokemon(id: Int64, name: String, type: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Pokemon")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let fetch = try managedContext.fetch(fetchRequest)
            let dataToUpdate = fetch[0] as! NSManagedObject
            
            dataToUpdate.setValue(type, forKey: "type")
            
            try managedContext.save()
        } catch let err {
            print ("Error Update \(err)")
        }
    }
    
    func deletePokemon(index: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Pokemon")
        fetchRequest.predicate = NSPredicate(format: "name = %@", self.pokemons[index.row].name)
        
        do {
            let dataToDelete = try managedContext.fetch(fetchRequest)[0] as! NSManagedObject
            managedContext.delete(dataToDelete)
            
            try managedContext.save()
        } catch let err {
            print("Error in Delete \(err)")
        }

    }
    
    func deleteAll() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                entityName: "Pokemon"
        )
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            result.forEach{pokemon in
                managedContext.delete(pokemon)
            }
        } catch let err {
            print("Error in Delete All \(err)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            deletePokemon(index: indexPath)
            self.getPokemon()
            self.pokemonTable.reloadData()
        }
    }

}

