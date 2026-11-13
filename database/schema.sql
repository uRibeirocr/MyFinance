--
-- PostgreSQL database dump
--

\restrict WcEKWUcdt6CC1lmVi0K6lrxKoSZ6ViGaOpp6GSMFuvSzjUcwomc5sUJGpAJxUQZ

-- Dumped from database version 18.7
-- Dumped by pg_dump version 18.7

-- Started on 2026-11-13 11:46:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 24595)
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    account_type character varying(20) NOT NULL,
    initial_balance numeric(14,2) DEFAULT 0 NOT NULL,
    currency character(3) DEFAULT 'BRL'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT accounts_account_type_check CHECK (((account_type)::text = ANY ((ARRAY['BANK'::character varying, 'WALLET'::character varying, 'SAVINGS'::character varying, 'OTHER'::character varying])::text[])))
);


ALTER TABLE public.accounts 

--
-- TOC entry 221 (class 1259 OID 24619)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT categories_type_check CHECK (((type)::text = ANY ((ARRAY['INCOME'::character varying, 'EXPENSE'::character varying])::text[])))
);


ALTER TABLE public.categories 

--
-- TOC entry 228 (class 1259 OID 24816)
-- Name: goal_contributions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.goal_contributions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    goal_id uuid NOT NULL,
    amount numeric(14,2) NOT NULL,
    contribution_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT goal_contributions_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE public.goal_contributions 

--
-- TOC entry 227 (class 1259 OID 24796)
-- Name: goals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.goals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    target_amount numeric(14,2) NOT NULL,
    deadline date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT goals_target_amount_check CHECK ((target_amount > (0)::numeric))
);


ALTER TABLE public.goals 

--
-- TOC entry 225 (class 1259 OID 24743)
-- Name: investment_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.investment_movements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    investment_id uuid NOT NULL,
    account_id uuid NOT NULL,
    movement_type character varying(20) NOT NULL,
    amount numeric(14,2) NOT NULL,
    movement_date date NOT NULL,
    description character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT investment_movements_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT investment_movements_movement_type_check CHECK (((movement_type)::text = ANY ((ARRAY['CONTRIBUTION'::character varying, 'REDEMPTION'::character varying, 'DIVIDEND'::character varying, 'INTEREST'::character varying, 'FEE'::character varying])::text[])))
);


ALTER TABLE public.investment_movements 

--
-- TOC entry 226 (class 1259 OID 24770)
-- Name: investment_valuations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.investment_valuations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    investment_id uuid NOT NULL,
    invested_amount numeric(14,2) NOT NULL,
    current_value numeric(14,2) NOT NULL,
    valuation_date date NOT NULL,
    source character varying(20) DEFAULT 'MANUAL'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT investment_valuations_current_value_check CHECK ((current_value >= (0)::numeric)),
    CONSTRAINT investment_valuations_invested_amount_check CHECK ((invested_amount >= (0)::numeric)),
    CONSTRAINT investment_valuations_source_check CHECK (((source)::text = ANY ((ARRAY['MANUAL'::character varying, 'AUTOMATIC'::character varying])::text[])))
);


ALTER TABLE public.investment_valuations 

--
-- TOC entry 224 (class 1259 OID 24723)
-- Name: investments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.investments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(150) NOT NULL,
    investment_type character varying(30) NOT NULL,
    institution character varying(100),
    ticker character varying(20),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT investments_investment_type_check CHECK (((investment_type)::text = ANY ((ARRAY['FIXED_INCOME'::character varying, 'STOCK'::character varying, 'REAL_ESTATE_FUND'::character varying, 'ETF'::character varying, 'OTHER'::character varying])::text[])))
);


ALTER TABLE public.investments 

--
-- TOC entry 223 (class 1259 OID 24681)
-- Name: recurring_expenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recurring_expenses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    account_id uuid NOT NULL,
    category_id uuid NOT NULL,
    category_type character varying(20) DEFAULT 'EXPENSE'::character varying NOT NULL,
    description character varying(200) NOT NULL,
    expected_amount numeric(14,2) NOT NULL,
    due_day smallint NOT NULL,
    frequency character varying(20) NOT NULL,
    due_month smallint,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_recurring_due_month CHECK (((((frequency)::text = 'MONTHLY'::text) AND (due_month IS NULL)) OR (((frequency)::text = 'YEARLY'::text) AND ((due_month >= 1) AND (due_month <= 12))))),
    CONSTRAINT recurring_expenses_category_type_check CHECK (((category_type)::text = 'EXPENSE'::text)),
    CONSTRAINT recurring_expenses_due_day_check CHECK (((due_day >= 1) AND (due_day <= 31))),
    CONSTRAINT recurring_expenses_expected_amount_check CHECK ((expected_amount > (0)::numeric)),
    CONSTRAINT recurring_expenses_frequency_check CHECK (((frequency)::text = ANY ((ARRAY['MONTHLY'::character varying, 'YEARLY'::character varying])::text[])))
);


ALTER TABLE public.recurring_expenses 

--
-- TOC entry 222 (class 1259 OID 24651)
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    account_id uuid NOT NULL,
    category_id uuid NOT NULL,
    type character varying(20) NOT NULL,
    description character varying(200) NOT NULL,
    amount numeric(14,2) NOT NULL,
    transaction_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recurring_expense_id uuid,
    CONSTRAINT transactions_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT transactions_type_check CHECK (((type)::text = ANY ((ARRAY['INCOME'::character varying, 'EXPENSE'::character varying])::text[])))
);


ALTER TABLE public.transactions 

--
-- TOC entry 229 (class 1259 OID 24835)
-- Name: transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    source_account_id uuid NOT NULL,
    destination_account_id uuid NOT NULL,
    amount numeric(14,2) NOT NULL,
    transfer_date date NOT NULL,
    description character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_transfer_different_accounts CHECK ((source_account_id <> destination_account_id)),
    CONSTRAINT transfers_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE public.transfers 

--
-- TOC entry 219 (class 1259 OID 24577)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users 

--
-- TOC entry 4947 (class 2606 OID 24611)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 4952 (class 2606 OID 24631)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4990 (class 2606 OID 24829)
-- Name: goal_contributions goal_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goal_contributions
    ADD CONSTRAINT goal_contributions_pkey PRIMARY KEY (id);


--
-- TOC entry 4985 (class 2606 OID 24808)
-- Name: goals goals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_pkey PRIMARY KEY (id);


--
-- TOC entry 4979 (class 2606 OID 24759)
-- Name: investment_movements investment_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment_movements
    ADD CONSTRAINT investment_movements_pkey PRIMARY KEY (id);


--
-- TOC entry 4981 (class 2606 OID 24788)
-- Name: investment_valuations investment_valuations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment_valuations
    ADD CONSTRAINT investment_valuations_pkey PRIMARY KEY (id);


--
-- TOC entry 4973 (class 2606 OID 24735)
-- Name: investments investments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT investments_pkey PRIMARY KEY (id);


--
-- TOC entry 4968 (class 2606 OID 24705)
-- Name: recurring_expenses recurring_expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_expenses
    ADD CONSTRAINT recurring_expenses_pkey PRIMARY KEY (id);


--
-- TOC entry 4963 (class 2606 OID 24668)
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 4994 (class 2606 OID 24850)
-- Name: transfers transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT transfers_pkey PRIMARY KEY (id);


--
-- TOC entry 4950 (class 2606 OID 24613)
-- Name: accounts uq_accounts_id_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT uq_accounts_id_user UNIQUE (id, user_id);


--
-- TOC entry 4955 (class 2606 OID 24633)
-- Name: categories uq_categories_id_user_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT uq_categories_id_user_type UNIQUE (id, user_id, type);


--
-- TOC entry 4957 (class 2606 OID 24635)
-- Name: categories uq_categories_user_name_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT uq_categories_user_name_type UNIQUE (user_id, name, type);


--
-- TOC entry 4988 (class 2606 OID 24810)
-- Name: goals uq_goals_id_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT uq_goals_id_user UNIQUE (id, user_id);


--
-- TOC entry 4983 (class 2606 OID 24790)
-- Name: investment_valuations uq_investment_valuation_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment_valuations
    ADD CONSTRAINT uq_investment_valuation_date UNIQUE (investment_id, valuation_date);


--
-- TOC entry 4975 (class 2606 OID 24737)
-- Name: investments uq_investments_id_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT uq_investments_id_user UNIQUE (id, user_id);


--
-- TOC entry 4970 (class 2606 OID 24707)
-- Name: recurring_expenses uq_recurring_id_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_expenses
    ADD CONSTRAINT uq_recurring_id_user UNIQUE (id, user_id);


--
-- TOC entry 4965 (class 2606 OID 24670)
-- Name: transactions uq_transactions_id_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT uq_transactions_id_user UNIQUE (id, user_id);


--
-- TOC entry 4943 (class 2606 OID 24594)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4945 (class 2606 OID 24592)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4948 (class 1259 OID 24866)
-- Name: idx_accounts_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_user ON public.accounts USING btree (user_id);


--
-- TOC entry 4953 (class 1259 OID 24867)
-- Name: idx_categories_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_user ON public.categories USING btree (user_id);


--
-- TOC entry 4991 (class 1259 OID 24878)
-- Name: idx_goal_contributions_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_goal_contributions_date ON public.goal_contributions USING btree (goal_id, contribution_date);


--
-- TOC entry 4986 (class 1259 OID 24877)
-- Name: idx_goals_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_goals_user ON public.goals USING btree (user_id);


--
-- TOC entry 4971 (class 1259 OID 24873)
-- Name: idx_investments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_investments_user ON public.investments USING btree (user_id);


--
-- TOC entry 4976 (class 1259 OID 24875)
-- Name: idx_movements_account_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_account_date ON public.investment_movements USING btree (account_id, movement_date);


--
-- TOC entry 4977 (class 1259 OID 24874)
-- Name: idx_movements_investment_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_movements_investment_date ON public.investment_movements USING btree (investment_id, movement_date);


--
-- TOC entry 4966 (class 1259 OID 24872)
-- Name: idx_recurring_expenses_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recurring_expenses_user ON public.recurring_expenses USING btree (user_id, is_active);


--
-- TOC entry 4958 (class 1259 OID 24869)
-- Name: idx_transactions_account_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_account_date ON public.transactions USING btree (account_id, transaction_date);


--
-- TOC entry 4959 (class 1259 OID 24870)
-- Name: idx_transactions_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_category ON public.transactions USING btree (category_id);


--
-- TOC entry 4960 (class 1259 OID 24871)
-- Name: idx_transactions_recurring; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_recurring ON public.transactions USING btree (recurring_expense_id) WHERE (recurring_expense_id IS NOT NULL);


--
-- TOC entry 4961 (class 1259 OID 24868)
-- Name: idx_transactions_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_user_date ON public.transactions USING btree (user_id, transaction_date);


--
-- TOC entry 4992 (class 1259 OID 24879)
-- Name: idx_transfers_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transfers_user_date ON public.transfers USING btree (user_id, transfer_date);


--
-- TOC entry 4995 (class 2606 OID 24614)
-- Name: accounts fk_accounts_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4996 (class 2606 OID 24636)
-- Name: categories fk_categories_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_categories_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5008 (class 2606 OID 24830)
-- Name: goal_contributions fk_contributions_goal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goal_contributions
    ADD CONSTRAINT fk_contributions_goal FOREIGN KEY (goal_id, user_id) REFERENCES public.goals(id, user_id);


--
-- TOC entry 5009 (class 2606 OID 24880)
-- Name: goal_contributions fk_contributions_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goal_contributions
    ADD CONSTRAINT fk_contributions_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5007 (class 2606 OID 24811)
-- Name: goals fk_goals_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT fk_goals_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5003 (class 2606 OID 24738)
-- Name: investments fk_investments_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT fk_investments_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5004 (class 2606 OID 24765)
-- Name: investment_movements fk_movements_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment_movements
    ADD CONSTRAINT fk_movements_account FOREIGN KEY (account_id, user_id) REFERENCES public.accounts(id, user_id);


--
-- TOC entry 5005 (class 2606 OID 24760)
-- Name: investment_movements fk_movements_investment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment_movements
    ADD CONSTRAINT fk_movements_investment FOREIGN KEY (investment_id, user_id) REFERENCES public.investments(id, user_id);


--
-- TOC entry 5000 (class 2606 OID 24713)
-- Name: recurring_expenses fk_recurring_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_expenses
    ADD CONSTRAINT fk_recurring_account FOREIGN KEY (account_id, user_id) REFERENCES public.accounts(id, user_id);


--
-- TOC entry 5001 (class 2606 OID 24718)
-- Name: recurring_expenses fk_recurring_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_expenses
    ADD CONSTRAINT fk_recurring_category FOREIGN KEY (category_id, user_id, category_type) REFERENCES public.categories(id, user_id, type);


--
-- TOC entry 5002 (class 2606 OID 24708)
-- Name: recurring_expenses fk_recurring_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recurring_expenses
    ADD CONSTRAINT fk_recurring_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4997 (class 2606 OID 24671)
-- Name: transactions fk_transactions_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_account FOREIGN KEY (account_id, user_id) REFERENCES public.accounts(id, user_id);


--
-- TOC entry 4998 (class 2606 OID 24676)
-- Name: transactions fk_transactions_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_category FOREIGN KEY (category_id, user_id, type) REFERENCES public.categories(id, user_id, type);


--
-- TOC entry 4999 (class 2606 OID 24861)
-- Name: transactions fk_transactions_recurring_expense; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_recurring_expense FOREIGN KEY (recurring_expense_id, user_id) REFERENCES public.recurring_expenses(id, user_id);


--
-- TOC entry 5010 (class 2606 OID 24856)
-- Name: transfers fk_transfer_destination; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT fk_transfer_destination FOREIGN KEY (destination_account_id, user_id) REFERENCES public.accounts(id, user_id);


--
-- TOC entry 5011 (class 2606 OID 24851)
-- Name: transfers fk_transfer_source; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT fk_transfer_source FOREIGN KEY (source_account_id, user_id) REFERENCES public.accounts(id, user_id);


--
-- TOC entry 5006 (class 2606 OID 24791)
-- Name: investment_valuations fk_valuations_investment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.investment_valuations
    ADD CONSTRAINT fk_valuations_investment FOREIGN KEY (investment_id, user_id) REFERENCES public.investments(id, user_id);


-- Completed on 2026-11-13 11:46:34

--
-- PostgreSQL database dump complete
--

\unrestrict WcEKWUcdt6CC1lmVi0K6lrxKoSZ6ViGaOpp6GSMFuvSzjUcwomc5sUJGpAJxUQZ

