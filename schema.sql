-- =====================================================
-- Achados & Perdidos do Campus - Esquema do banco
-- Execute no Supabase: SQL Editor > New query > Run
-- =====================================================

create table if not exists categorias (
  id   bigint generated always as identity primary key,
  nome text not null unique
);

create table if not exists locais (
  id   bigint generated always as identity primary key,
  nome text not null unique
);

create table if not exists itens (
  id              bigint generated always as identity primary key,
  descricao       text not null,
  categoria_id    bigint not null references categorias(id) on delete restrict,
  local_id        bigint not null references locais(id) on delete restrict,
  data            date not null default current_date,
  status          text not null default 'encontrado'
                  check (status in ('perdido', 'encontrado', 'devolvido')),
  contato         text,                 -- quem cadastrou (opcional)
  retirado_por    text,                 -- preenchido ao devolver
  data_devolucao  timestamptz,          -- preenchido ao devolver
  criado_em       timestamptz not null default now()
);

create index if not exists idx_itens_status on itens(status);
create index if not exists idx_itens_categoria on itens(categoria_id);

-- Seguranca: ativa RLS. A API usa a chave service_role (ignora o RLS),
-- entao ninguem consegue acessar os dados direto pela chave publica.
alter table categorias enable row level security;
alter table locais     enable row level security;
alter table itens      enable row level security;

-- Dados iniciais para facilitar os testes
insert into categorias (nome) values
  ('Eletrônicos'), ('Documentos'), ('Roupas'), ('Material escolar'), ('Outros')
on conflict (nome) do nothing;

insert into locais (nome) values
  ('Bloco A'), ('Bloco B'), ('Biblioteca'), ('Cantina'), ('Estacionamento')
on conflict (nome) do nothing;
