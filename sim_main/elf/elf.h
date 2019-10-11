/* ELF support for BFD.
   Copyright (C) 1991-2014 Free Software Foundation, Inc.

   Written by Fred Fish @ Cygnus Support, from information published
   in "UNIX System V Release 4, Programmers Guide: ANSI C and
   Programming Support Tools".

   This file is part of BFD, the Binary File Descriptor library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

/* This file is part of ELF support for BFD, and contains the portions
   that describe how ELF is represented externally by the BFD library.
   I.E. it describes the in-file representation of ELF.  It requires
   the elf/common.h file which contains the portions that are common to
   both the internal and external representations.  */

/* The 64-bit stuff is kind of random.  Perhaps someone will publish a
   spec someday.  */

#ifndef _ELF_H
#define _ELF_H

#include <stdint.h>

/* Special section indices, which may show up in st_shndx fields, among
   other places.  */

#define SHN_LORESERVE	0xFF00		/* Begin range of reserved indices */
#define SHN_LOPROC	0xFF00		/* Begin range of appl-specific */
#define SHN_HIPROC	0xFF1F		/* End range of appl-specific */
#define SHN_LOOS	0xFF20		/* OS specific semantics, lo */
#define SHN_HIOS	0xFF3F		/* OS specific semantics, hi */
#define SHN_ABS		0xFFF1		/* Associated symbol is absolute */
#define SHN_COMMON	0xFFF2		/* Associated symbol is in common */
#define SHN_XINDEX	0xFFFF		/* Section index is held elsewhere */
#define SHN_HIRESERVE	0xFFFF		/* End range of reserved indices */

/* ELF Header (32-bit implementations) */

typedef struct {
  unsigned char	e_ident[16];		/* ELF "magic number" */
  uint16_t	e_type;		/* Identifies object file type */
  uint16_t	e_machine;		/* Specifies required architecture */
  uint32_t	e_version;		/* Identifies object file version */
  uint32_t	e_entry;		/* Entry point virtual address */
  uint32_t	e_phoff;		/* Program header table file offset */
  uint32_t	e_shoff;		/* Section header table file offset */
  uint32_t	e_flags;		/* Processor-specific flags */
  uint16_t	e_ehsize;		/* ELF header size in bytes */
  uint16_t	e_phentsize;		/* Program header table entry size */
  uint16_t	e_phnum;		/* Program header table entry count */
  uint16_t	e_shentsize;		/* Section header table entry size */
  uint16_t	e_shnum;		/* Section header table entry count */
  uint16_t	e_shstrndx;		/* Section header string table index */
} Elf32_External_Ehdr;

typedef struct {
  unsigned char	e_ident[16];		/* ELF "magic number" */
  uint16_t	e_type;		/* Identifies object file type */
  uint16_t	e_machine;		/* Specifies required architecture */
  uint32_t	e_version;		/* Identifies object file version */
  uint64_t	e_entry;		/* Entry point virtual address */
  uint64_t	e_phoff;		/* Program header table file offset */
  uint64_t	e_shoff;		/* Section header table file offset */
  uint32_t	e_flags;		/* Processor-specific flags */
  uint16_t	e_ehsize;		/* ELF header size in bytes */
  uint16_t	e_phentsize;		/* Program header table entry size */
  uint16_t	e_phnum;		/* Program header table entry count */
  uint16_t	e_shentsize;		/* Section header table entry size */
  uint16_t	e_shnum;		/* Section header table entry count */
  uint16_t	e_shstrndx;		/* Section header string table index */
} Elf64_External_Ehdr;

/* Program header */

typedef struct {
  uint32_t	p_type;		/* Identifies program segment type */
  uint32_t	p_offset;		/* Segment file offset */
  uint32_t	p_vaddr;		/* Segment virtual address */
  uint32_t	p_paddr;		/* Segment physical address */
  uint32_t	p_filesz;		/* Segment size in file */
  uint32_t	p_memsz;		/* Segment size in memory */
  uint32_t	p_flags;		/* Segment flags */
  uint32_t	p_align;		/* Segment alignment, file & memory */
} Elf32_External_Phdr;

typedef struct {
  uint32_t	p_type;		/* Identifies program segment type */
  uint32_t	p_flags;		/* Segment flags */
  uint64_t	p_offset;		/* Segment file offset */
  uint64_t	p_vaddr;		/* Segment virtual address */
  uint64_t	p_paddr;		/* Segment physical address */
  uint64_t	p_filesz;		/* Segment size in file */
  uint64_t	p_memsz;		/* Segment size in memory */
  uint64_t	p_align;		/* Segment alignment, file & memory */
} Elf64_External_Phdr;

/* Section header */

typedef struct {
  uint32_t	sh_name;		/* Section name, index in string tbl */
  uint32_t	sh_type;		/* Type of section */
  uint32_t	sh_flags;		/* Miscellaneous section attributes */
  uint32_t	sh_addr;		/* Section virtual addr at execution */
  uint32_t	sh_offset;		/* Section file offset */
  uint32_t	sh_size;		/* Size of section in bytes */
  uint32_t	sh_link;		/* Index of another section */
  uint32_t	sh_info;		/* Additional section information */
  uint32_t	sh_addralign;	/* Section alignment */
  uint32_t	sh_entsize;		/* Entry size if section holds table */
} Elf32_External_Shdr;

typedef struct {
  uint32_t	sh_name;		/* Section name, index in string tbl */
  uint32_t	sh_type;		/* Type of section */
  uint64_t	sh_flags;		/* Miscellaneous section attributes */
  uint64_t	sh_addr;		/* Section virtual addr at execution */
  uint64_t	sh_offset;		/* Section file offset */
  uint64_t	sh_size;		/* Size of section in bytes */
  uint32_t	sh_link;		/* Index of another section */
  uint32_t	sh_info;		/* Additional section information */
  uint64_t	sh_addralign;	/* Section alignment */
  uint64_t	sh_entsize;		/* Entry size if section holds table */
} Elf64_External_Shdr;

/* Symbol table entry */

typedef struct {
  uint32_t	st_name;		/* Symbol name, index in string tbl */
  uint32_t	st_value;		/* Value of the symbol */
  uint32_t	st_size;		/* Associated symbol size */
  uint8_t	st_info;		/* Type and binding attributes */
  uint8_t	st_other;		/* No defined meaning, 0 */
  uint16_t	st_shndx;		/* Associated section index */
} Elf32_External_Sym;

typedef struct {
  uint32_t	st_name;		/* Symbol name, index in string tbl */
  uint8_t	st_info;		/* Type and binding attributes */
  uint8_t	st_other;		/* No defined meaning, 0 */
  uint16_t	st_shndx;		/* Associated section index */
  uint64_t	st_value;		/* Value of the symbol */
  uint64_t	st_size;		/* Associated symbol size */
} Elf64_External_Sym;

typedef struct {
  uint32_t est_shndx;		/* Section index */
} Elf_External_Sym_Shndx;

/* Note segments */

typedef struct {
  uint32_t	namesz;		/* Size of entry's owner string */
  uint32_t	descsz;		/* Size of the note descriptor */
  uint32_t	type;		/* Interpretation of the descriptor */
  char		name[1];		/* Start of the name+desc data */
} Elf_External_Note;

/* Relocation Entries */
typedef struct {
  uint32_t r_offset;	/* Location at which to apply the action */
  uint32_t	r_info;	/* index and type of relocation */
} Elf32_External_Rel;

typedef struct {
  uint32_t r_offset;	/* Location at which to apply the action */
  uint32_t	r_info;	/* index and type of relocation */
  uint32_t	r_addend;	/* Constant addend used to compute value */
} Elf32_External_Rela;

typedef struct {
  uint64_t r_offset;	/* Location at which to apply the action */
  uint64_t	r_info;	/* index and type of relocation */
} Elf64_External_Rel;

typedef struct {
  uint64_t r_offset;	/* Location at which to apply the action */
  uint64_t	r_info;	/* index and type of relocation */
  uint64_t	r_addend;	/* Constant addend used to compute value */
} Elf64_External_Rela;

/* dynamic section structure */

typedef struct {
  uint32_t	d_tag;		/* entry tag value */
  union {
    uint32_t	d_val;
    uint32_t	d_ptr;
  } d_un;
} Elf32_External_Dyn;

typedef struct {
  uint64_t	d_tag;		/* entry tag value */
  union {
    uint64_t	d_val;
    uint64_t	d_ptr;
  } d_un;
} Elf64_External_Dyn;

/* The version structures are currently size independent.  They are
   named without a 32 or 64.  If that ever changes, these structures
   will need to be renamed.  */

/* This structure appears in a SHT_GNU_verdef section.  */

typedef struct {
  uint16_t		vd_version;
  uint16_t		vd_flags;
  uint16_t		vd_ndx;
  uint16_t		vd_cnt;
  uint32_t		vd_hash;
  uint32_t		vd_aux;
  uint32_t		vd_next;
} Elf_External_Verdef;

/* This structure appears in a SHT_GNU_verdef section.  */

typedef struct {
  uint32_t		vda_name;
  uint32_t		vda_next;
} Elf_External_Verdaux;

/* This structure appears in a SHT_GNU_verneed section.  */

typedef struct {
  uint16_t		vn_version;
  uint16_t		vn_cnt;
  uint32_t		vn_file;
  uint32_t		vn_aux;
  uint32_t		vn_next;
} Elf_External_Verneed;

/* This structure appears in a SHT_GNU_verneed section.  */

typedef struct {
  uint32_t		vna_hash;
  uint16_t		vna_flags;
  uint16_t		vna_other;
  uint32_t		vna_name;
  uint32_t		vna_next;
} Elf_External_Vernaux;

/* This structure appears in a SHT_GNU_versym section.  This is not a
   standard ELF structure; ELF just uses Elf32_Half.  */

typedef struct {
  uint16_t		vs_vers;
} __attribute__((packed))  Elf_External_Versym;

/* Structure for syminfo section.  */
typedef struct
{
  uint16_t		si_boundto;
  uint16_t		si_flags;
} Elf_External_Syminfo;


/* This structure appears on the stack and in NT_AUXV core file notes.  */
typedef struct
{
  uint32_t		a_type;
  uint32_t		a_val;
} Elf32_External_Auxv;

typedef struct
{
  uint64_t		a_type;
  uint64_t		a_val;
} Elf64_External_Auxv;

/* Size of SHT_GROUP section entry.  */

#define GRP_ENTRY_SIZE		4

#endif /* _ELF_H */
