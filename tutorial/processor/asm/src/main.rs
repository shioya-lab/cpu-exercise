use clap::{App, Arg};
use anyhow::{Result, bail};
use std::io::{BufRead, BufReader, Write};
use std::fs::File;

fn main() -> Result<()>{
    let matches = App::new("dumb assembler")
    .version("1.0.0")
    .author("toka")
    .about("dumb assembler")
    .arg(
        Arg::new("infile")
        .about("assembly file to assemble")
        .value_name("FILE")
        .index(1)
        .required(true),
    )
    .arg(
        Arg::new("outfile")
        .about("binary output file")
        .value_name("OUTPUT")
        .index(2)
        .required(true),
    )
    .get_matches();
    

    match matches.value_of("infile"){
        Some(infile) => {
            match matches.value_of("outfile"){
                Some(outfile) => {
                    let inf = File::open(infile)?;
                    let outf = File::create(outfile)?;
                    let inreader = BufReader::new(inf);
                    run(inreader, outf)
                },
                None => {
                    println!("No output file specified");
                    Ok(())
                }
            }
        },
        None => {
            println!("No input file specified");
            Ok(())
        }
    }
}

fn getreg(inp :&str, with_disp: bool) -> Result<(u32, i16)>{
    if with_disp{
        let bracket_beg = inp.find("(");
        let bracket_end = inp.find(")");
        match (bracket_beg, bracket_end) {
            (Some(beg), Some(end)) => {
                let disp = inp[..beg].parse()?;
                println!("{}",disp);
                let regnum = inp[(beg+2)..end].parse()?;
                Ok((regnum, disp))
            }
            _ => {
                bail!("invalid assmbly code!");
            }
        }
    }
    else{
        match &inp[..1] {
            "$" => {
                return Ok((inp[1..].parse()?, 0))
            }
            _ => {
                bail!("invalid assembly code!");
            }
        }
    }
}

fn run <R: BufRead>(inreader : R, mut out :File) -> Result<()>{
    for line in inreader.lines(){
        let line = line.unwrap();
        let line = line.trim();
        println!("{}", line);
        let tokens = line.split_whitespace().collect::<Vec<_>>();
        let mut inst : u32 = 0;
        match tokens.len(){
            3 => {
                //lw, sw
                if tokens[0] == "lw"{
                    inst = inst | (35 << 26);

                }
                else if tokens[0] == "sw" {
                    inst = inst | (43 << 26);
                }
                else{
                    bail!("invalid assmbly code!");
                }
                let (rt, _) = getreg(tokens[1], false)?;
                let (rs, disp) = getreg(tokens[2], true)?;

                inst = inst | (rs << 21);
                inst = inst | (rt << 16);
                inst = inst | (disp as u32);

                write!(out, "{:08x}\n", inst)?;
            }
            4 => {
                match tokens[0] {
                    //alu
                    "add" | "sub" | "and" | "or" | "xor" | "slt" => {
                        inst = inst | (0 << 26);
                        let (rd, _) = getreg(tokens[1], false)?;
                        let (rs, _) = getreg(tokens[2], false)?;
                        let (rt, _) = getreg(tokens[3], false)?;
                        inst = inst | (rs << 21);
                        inst = inst | (rt << 16);
                        inst = inst | (rd << 11);
                        inst = inst | (0 << 6);
                        if tokens[0] == "add"{
                            inst = inst | (32);
                        }
                        else if tokens[0] == "sub"{
                            inst = inst | (34);
                        }
                        else if tokens[0] == "and"{
                            inst = inst | (36);
                        }
                        else if tokens[0] == "or"{
                            inst = inst | (37);
                        }
                        else if tokens[0] == "xor"{
                            inst = inst | (38);
                        }
                        else if tokens[0] == "slt"{
                            inst = inst | (42);
                        }
                        write!(out, "{:08x}\n", inst)?;
                    },
                    "sll" | "slr" => {
                        inst = inst | (0 << 26);
                        let (rd, _) = getreg(tokens[1], false)?;
                        let (rt, _) = getreg(tokens[2], false)?;
                        let shamt : u32 = tokens[3].parse()?;
                        inst = inst | (0 << 21);
                        inst = inst | (rt << 16);
                        inst = inst | (rd << 11);
                        inst = inst | (shamt << 6);
                        if tokens[0] == "sll"{
                            inst = inst | (0);
                        }
                        else if tokens[0] == "srl"{
                            inst = inst | (2);
                        }
                        write!(out, "{:08x}\n", inst)?;
                    }
                    "andi" | "addi" | "ori" => {
                        if tokens[0] == "addi"{
                            inst = inst | (8 << 26);
                        }
                        else if tokens[0] == "andi"{
                            inst = inst | (12 << 26);
                        }
                        else if tokens[0] == "ori"{
                            inst = inst | (13 << 26);
                        }
                        let (rt, _) = getreg(tokens[1], false)?;
                        let (rs, _) = getreg(tokens[2], false)?;  
                        inst = inst | (rs << 21);
                        inst = inst | (rt << 16);
                        let imm : i16 = tokens[3].parse()?;
                        inst = inst | (imm as u32);
                        write!(out, "{:08x}\n", inst)?;
                    }
                    "bne" | "beq" => {
                        if tokens[0] == "bne"{
                            inst = inst | (5 << 26);
                        }
                        else if tokens[0] == "beq"{
                            inst = inst | (4 << 26);
                        }
                        let (rs, _) = getreg(tokens[1], false)?;
                        let (rt, _) = getreg(tokens[2], false)?;  
                        inst = inst | (rs << 21);
                        inst = inst | (rt << 16);

                        let imm : i16 = tokens[3].parse()?;
                        inst = inst | (imm as u32);
                        write!(out, "{:08x}\n", inst)?;
                    }
                    _ => {
                        bail!("invalid assembly code!");
                    }
                }
            }
            _ => {
                bail!("invalid assembly code!");
            }
        }
    }
    Ok(())
}
