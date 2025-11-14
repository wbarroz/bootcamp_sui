module bootcamp_sui::livros {
    use sui::dynamic_field;
    use std::string::String;

    public struct Livro has key, store {
        id: UID,
        titulo: String,
        autor: String,
        ano: u16
    }

    public struct Biblioteca has key, store {
        id: UID,
        nome: String,
        total_livros: u64
    }

    public fun criar_biblioteca(nome: String, ctx: &mut TxContext) {
        let biblioteca = Biblioteca {
            id: object::new(ctx),
            nome,
            total_livros: 0
        };
        transfer::share_object(biblioteca);
    }

    public fun adicionar_livro(
        biblioteca: &mut Biblioteca,
        titulo: String,
        autor: String,
        ano: u16,
        conteudo_walrus: vector<u8>, // ID do arquivo no Walrus
        ctx: &mut TxContext
    ) {
        let mut livro = Livro {
            id: object::new(ctx),
            titulo,
            autor,
            ano
        };

        dynamic_field::add(&mut livro.id, b"conteudo_walrus", conteudo_walrus);
        dynamic_field::add(&mut livro.id, b"disponivel", true);

        let livro_id = object::uid_to_inner(&livro.id);
        dynamic_field::add(&mut biblioteca.id, livro_id, livro);
        
        biblioteca.total_livros = biblioteca.total_livros + 1;
    }

    public fun emprestar_livro(biblioteca: &mut Biblioteca, livro_id: ID) {
        let livro: &mut Livro = dynamic_field::borrow_mut(&mut biblioteca.id, livro_id);
        let _old_status: bool = dynamic_field::remove(&mut livro.id, b"disponivel");
        dynamic_field::add(&mut livro.id, b"disponivel", false);
    }
}

